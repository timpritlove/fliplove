# Font subsystem: memory safety and eliminating delays

## Current state (reverted)

[`lib/fliplove/font/library.ex`](lib/fliplove/font/library.ex) again:

- Keeps **all parsed BDF fonts in GenServer state** (`state.fonts`).
- On `init`, schedules **~200 concurrent `Parser.parse_font/1` tasks** (full glyph parse) via `Task.Supervisor.async_nolink/3`.
- Each completed font **broadcasts** `font_library_update` (many PubSub events while the list grows).
- **`get_font_by_name/1`** only finds fonts via `Enum.find(state.fonts, fn font -> font.name == font_name end)` — it matches the **long BDF `FONT` name**, not the filename stem (if the UI ever passes a stem, lookup fails until that font happens to be in the list).

This matches the earlier behaviour that caused **high process heap** (`process_memory_high_watermark` on `Fliplove.Font.Library`) and several **delay / jank** sources.

## What we had agreed before (lost implementation)

1. **ETS** — store font structs in an ETS table so the Library process does not hold ~100MB+ in its heap (avoids memsup alarm on that process).
2. **Two-phase BDF handling**
   - **Phase A (cheap):** `Parser.parse_font_header/1` — NimbleParsec path that parses only through **ENDPROPERTIES**; returns `%Fliplove.Font{}` with **`characters: %{}`** but real **`name`** and **`properties`** (so clients like LiveView never need “placeholder” maps).
   - **Phase B (expensive):** `Parser.parse_font/1` — full parse with glyphs; run **only when a font is actually needed for rendering** (first `get_font_by_name` that needs glyphs), then replace the ETS entry with the full font.
3. **`get_fonts/0`** — return the **full list** of fonts for the selector: built-ins + every BDF, each as a proper `%Font{}` (header-only until upgraded).
4. **`name_to_path`** — map both **filename stem** and **long `font.name`** to filesystem path so lazy full parse can resolve keys from the UI.

## Where delays come from (and how to remove them)

### A. Startup / supervision delay

**Cause:** Blocking the Library `init` with a long sequential loop (e.g. 200+ header parses) delays application startup.

**Plan:**

- Keep `init` **minimal**: create ETS table, insert 3 built-ins, record `bdf_paths` (stem → path).
- Defer bulk work with **`{:ok, state, {:continue, :load_bdf_headers}}`** (or a single `spawn_link` / supervised task) so the process starts quickly.
- **Parallelise header parsing** with `Task.async_stream(Map.values(bdf_paths), fn path -> … end, max_concurrency: 8..16, timeout: :infinity)` (or `Task.Supervisor` + bounded concurrency). Writers insert into ETS; failures log and skip.
- Emit **one** `Phoenix.PubSub.broadcast` when the header phase completes (optional second broadcast when a full font is loaded later), instead of one broadcast per font during full parallel parse.

### B. UI / LiveView “stuttering” or slow first paint

**Cause:** Today, **one PubSub per parsed font** makes the font list grow in many steps; `get_fonts` may return a partial list early.

**Plan:**

- After header phase completes, **single broadcast** so LiveView refreshes once with the **complete** font list (all names + properties for grouping/display).
- Ensure `get_fonts/0` returns a **stable sorted order** (e.g. built-ins first, then sorted stems) for predictable UI.

### C. First-render / first-selection delay (full glyph parse)

**Cause:** If the first `get_font_by_name` does a **synchronous** full parse inside `GenServer.call`, the **calling process blocks** for large BDFs (bad for LiveView and HTTP).

**Plan (pick one primary approach):**

- **Recommended:** **`get_font_by_name` stays synchronous for already-loaded full fonts**, but for **header-only** fonts:
  - Option **C1 — Parse in caller-linked task:** Add `Library.ensure_font_loaded!(name)` or extend `get_font_by_name` to optionally use `Task.async` + `Task.await` **outside** the GenServer (e.g. a pure `Parser.parse_font(path)` after path resolve from ETS metadata), then **one** `GenServer.cast` to insert into ETS. (Requires careful deduping so two requests don’t double-parse — use `:ets.update_counter` / “loading” placeholder or a single-flight table.)
  - Option **C2 — Library internal Task + reply:** `handle_call` returns `{:reply, {:loading, name}, state}` and later pushes via PubSub when ready (bigger LiveView change).
  - **Pragmatic default:** Keep synchronous full parse **inside** `handle_call` for simplicity **but** move **CPU-heavy work** to `Task.Supervisor` with **`Task.await`** in the Library only if we accept blocking the GenServer (still blocks clients). Better: **C1** with a small **preload** after headers (background `Task.async_stream` full-parse for N most-used fonts from config) to hide first-use delay.

Document the chosen option in the implementation PR.

### D. Lookup mismatch delay / “wrong font”

**Cause:** `get_font_by_name` only matching `font.name` misses **stem** keys unless ETS stores **both** keys for the same font (header and full).

**Plan:** On header insert and on full insert, always register **stem** and **`font.name`** in ETS (and `name_to_path` for both → path).

## Implementation checklist (files)

| Area | File | Change |
|------|------|--------|
| Parser | [`lib/fliplove/font/parser.ex`](lib/fliplove/font/parser.ex) | Re-add `:bdf_header` combinator + `defparsec(:parse_bdf_header, …)` + `parse_font_header/1` (no glyph validation). |
| Library | [`lib/fliplove/font/library.ex`](lib/fliplove/font/library.ex) | ETS table; built-ins; `bdf_paths`; parallel header load in `continue`; `name_to_path`; `get_fonts` from ETS; `get_font_by_name` upgrades header→full with path resolve; **dedupe** full parse; **single** broadcast after headers; remove storing full font list in process state. |
| LiveView | [`lib/fliplove_web/live/fliplove_live.ex`](lib/fliplove_web/live/fliplove_live.ex) | No placeholder logic needed (all fonts have `properties` from header). Optionally subscribe once after fonts “ready” if we add a dedicated message. |
| HTTP | [`lib/fliplove/apps/fluepdot_server.ex`](lib/fliplove/apps/fluepdot_server.ex) | `/fonts` and any path that lists fonts: still works if `get_fonts` returns `%Font{}` with `properties`. |
| Tests | `test/...` (add or extend) | Unit test `parse_font_header` on a small fixture; Library test that `get_fonts` length matches built-ins + `.bdf` count; `get_font_by_name` returns glyphs after first load. |

## Success criteria

- **Memory:** `Fliplove.Font.Library` process heap stays small; font payload primarily in ETS (or on disk until loaded).
- **Startup:** Application supervision not blocked by long synchronous loops; header phase completes in bounded wall time via concurrency.
- **UI:** Font list appears **complete** after at most **one** refresh from the “fonts ready” event (no per-font spam).
- **Interaction:** First use of a heavy font does **not** freeze the LiveView longer than necessary (prefer async full load or preload per plan C).

## Out of scope (later)

- **Compact glyph storage** (binary/bitmaps instead of `%Bitmap{matrix: %{}}`) for further RAM reduction — orthogonal to delay work.
- **Allowlist** of BDFs if disk set grows again.
