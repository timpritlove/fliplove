# Fluepdot Sysinfo LiveView

## Mission

When Fliplove is connected to a Fluepdot display via USB, we have a direct serial command channel available for device management. Today that channel is only used for display output. This plan adds a `/sysinfo` LiveView page that retrieves device information (firmware version, full system config) and allows editing **WiFi settings and hostname** — the runtime-configurable items we care about right now. Both settings require a reboot to take effect, so the page also provides a Reboot button and reflects the device's rebooting/reconnecting state.

## Current Situation

### What exists

- **`Fliplove.Driver.FluepdotUsb`** — a GenServer that owns the USB serial connection. It maintains an ordered command queue (plain `[string]`), sends one command at a time, and waits for the device prompt (`/\n<hostname>> $/`) before sending the next. Responses are logged but **never surfaced to callers**.
- **`FliploveLive`** (`/`) — has a "USB Commands" section (visible only in USB mode) with simple fire-and-forget buttons (clear, reboot, wifi on/off, etc.).
- **`Fliplove.Apps`** — manages a single running display app (dashboard, timetable, slideshow…). Running apps call `Display.set(bitmap)` on a timer, which broadcasts `{:display_updated, bitmap}` over PubSub. The USB driver subscribes to that topic and enqueues a `framebuf64 <base64>` command for every update — potentially many per second.

### The problems to solve

1. **No response channel.** The USB driver swallows all response text. We need a way to capture the text between a command and the next prompt and deliver it to a caller.
2. **Queue starvation.** If an app is running, the command queue can fill up with `framebuf64` entries. A sysinfo query naively appended would wait behind all of them, making the LiveView appear unresponsive.
3. **No separation of concerns.** All USB interaction lives directly in `FliploveLive`. A dedicated sysinfo page needs its own module hierarchy.
4. **No driver state visibility.** The driver tracks `ready` internally but never broadcasts state changes. After a reboot the LiveView has no way to know when the device comes back online.

---

## Architecture

```
FliploveLive  ──link──►  SysinfoLive
                            │   subscribe to "usb_responses"
                            │
                       Fliplove.Sysinfo   (plain module)
                         query_version()      ──►  FluepdotUsb.query("show_version", :version)
                         query_config()       ──►  FluepdotUsb.query("config_show", :config)
                         save_wifi_station/2  ──►  FluepdotUsb.command_sequence([...])
                         save_wifi_ap/2       ──►  FluepdotUsb.command_sequence([...])
                         save_hostname/1      ──►  FluepdotUsb.command_sequence([...])
                         reboot/0             ──►  FluepdotUsb.command_sequence([{:display, "reboot"}])
                         parse_version/1
                         parse_config/1
                            │
                       FluepdotUsb  (GenServer)
                         priority queue:
                           {:query, cmd, tag}  ──front──►  serial
                           {:display, cmd}     ──back───►  serial
                         on prompt received:
                           if last was {:query, _, tag} →
                             broadcast {:usb_response, tag, text}   on "usb_responses"
                           always →
                             broadcast {:usb_driver_state, :ready}  on "usb_responses"
```

**`Fliplove.Sysinfo`** is a plain module (no GenServer) — a cohesive unit for USB device management logic. It knows about commands, parsing, and sequencing. The LiveView subscribes directly to PubSub and calls parser functions; no intermediate process is needed.

---

## Device State Model

### Driver-level states

The `FluepdotUsb` GenServer has exactly three meaningful states:

| Internal state | Meaning |
|---|---|
| `connected: false` | USB port not open (initial, or after physical disconnect) |
| `connected: true, ready: false` | Port open; command in flight or awaiting initial prompt |
| `connected: true, ready: true` | Prompt received; next command may be sent |

The "waiting" state covers everything where a prompt hasn't arrived yet: the initial handshake, a `show_version` query, a `config_save`, and a `reboot` — the driver sees no difference between them. **There is no separate "rebooting" state at the driver level.**

### LiveView `device_state` assign

Maps driver states to four values:

```
:not_configured   – FLIPLOVE_DRIVER != FLUEPDOT_USB; driver not running
:disconnected     – driver running but USB port not open
:waiting          – port open; command in flight or awaiting initial prompt
:ready            – prompt received; device operational
```

### `last_action` assign (UI context, orthogonal to device state)

The LiveView knows *why* it is waiting because it triggered the action. A separate `last_action` assign carries that context:

```
nil / :initial  →  "Connecting…"           (subtle spinner on info cards)
:save           →  "Saving…"               (brief; shown on the Save button only)
:reboot         →  "Rebooting, please wait…" (prominent banner; long wait)
```

`last_action` is set by the LiveView itself the moment an action is triggered (no driver broadcast needed). It is cleared when `device_state` returns to `:ready`.

**The auto-refresh rule:** when `{:usb_driver_state, :ready}` arrives and `last_action == :reboot`, automatically call `Sysinfo.query_config()` to refresh the info cards after the device comes back.

### What the driver broadcasts (new additions)

- `{:usb_driver_state, :ready}` — emitted on every prompt detection (not reboot-specific).
- `{:usb_driver_state, :disconnected}` — emitted when the USB port drops (`:einval` or close).

The driver never needs to know what `:reboot` means semantically; it just detects prompts.

### Reboot mechanics

After `reboot` is sent, the device emits a multi-second boot log (~6 s in practice) ending in the prompt. The existing driver handles this correctly:

- `ready: false` holds the queue; display frames from running apps accumulate.
- `prompt_timeout` keeps sending `\n` every 3 s until the device responds.
- Once the prompt appears, the driver transitions to `ready: true` and drains the queue.

No driver changes are needed for reboot handling itself. The only addition is the `{:usb_driver_state, :ready}` broadcast so the LiveView knows when the device is back.

**Reboot button placement:** inside the USB Commands card, not inside the WiFi or Configuration cards. It is a general device action. Both settings cards carry an inline note: "Takes effect after reboot."

---

## Collision / Priority Prevention

Running apps produce a continuous stream of `framebuf64` display commands. Without mitigation, a sysinfo query appended to the tail of the queue would wait behind all pending display commands.

**Solution: two-tier command queue**

Change queue entries from plain strings to tagged tuples:

```elixir
# display priority (goes to back)
{:display, "framebuf64 <base64>"}

# sysinfo priority (prepended — goes to front)
{:query, "show_version", :version}
{:query, "config_show", :config}
```

When `FluepdotUsb.query/2` is called, the tagged tuple is **prepended** to the queue. Display commands are always **appended**. The device processes them in strict serial order, so a query always runs before the next display frame, not after all pending ones.

For WiFi saves (multi-step: `config_wifi_station …` + `config_save` + `config_show`), the entire sequence is prepended atomically as a list of tuples so they stay consecutive.

---

## Changes by File

### `lib/fliplove/driver/fluepdot_usb.ex`

- Change `command_queue` entries to tagged tuples: `{:display, cmd}` or `{:query, cmd, tag}`.
- Update `write_command/2` (display path) to wrap in `{:display, cmd}` and append.
- Add `query/2` public API: `GenServer.cast(__MODULE__, {:query_command, cmd, tag})` — prepends `{:query, cmd, tag}`.
- Add `command_sequence/1` public API: prepends a list of mixed-tagged tuples atomically (used by Sysinfo for multi-step save and reboot flows).
- Track `last_sent: nil | {:display} | {:query, tag}` in state (replaces `last_sent_command` string).
- In the prompt-detection branch:
  - If `last_sent` is `{:query, tag}`, extract response text (strip echoed command line from buffer), broadcast `{:usb_response, tag, cleaned_text}` on `Fliplove.PubSub` / `"usb_responses"`.
  - Always broadcast `{:usb_driver_state, :ready}` on the same topic (any subscriber needing to know the device came back online can use this).
- Add `topic()` returning `"usb_responses"`.
- Update init commands (e.g. `wifi stop`, `config_rendering_mode differential`, `flipdot_clear`) to use `{:display, cmd}` format.

### `lib/fliplove/sysinfo.ex` _(new file)_

```
Fliplove.Sysinfo
  query_version/0     – calls FluepdotUsb.query("show_version", :version)
  query_config/0      – calls FluepdotUsb.query("config_show", :config)
  save_wifi_station/2 – sequences: config_wifi_station "ssid" "pass", config_save, then re-queries config
  save_wifi_ap/2      – sequences: config_wifi_ap "ssid" "pass", config_save, then re-queries config
  save_hostname/1     – sequences: config_hostname "hostname", config_save, then re-queries config
  reboot/0            – sends {:display, "reboot"} via command_sequence (display-priority; no response expected)
  parse_version/1     – returns %{idf_version:, model:, cores:, features:, revision:}
  parse_config/1      – returns %{hostname:, wifi_mode:, ssid:, password:, rs485:, panels:, rendering_mode:}
  topic/0             – delegates to FluepdotUsb.topic()
```

WiFi mode convention (from device output): `mode=1` → AP, `mode=2` → Station.

All multi-step sequences (save + re-query) use `FluepdotUsb.command_sequence/1` to prepend the entire list atomically, keeping them consecutive in the queue.

Parsing uses regex/string splitting on the known output formats; no external dependency needed.

### `lib/fliplove_web/live/sysinfo_live.ex` _(new file)_

**Assigns:**
- `:device_state` — `:not_configured | :disconnected | :waiting | :ready`
- `:last_action` — `nil | :initial | :save | :reboot` (UI context for `:waiting`)
- `:version` — parsed map or `nil`
- `:config` — parsed map or `nil`
- `:wifi_form` — `to_form(...)` for SSID / password / AP-mode checkbox
- `:hostname_form` — `to_form(...)` for hostname field

**Lifecycle:**
- `mount/3`:
  - If not USB mode → set `device_state: :not_configured`, return early
  - Else → subscribe to `Sysinfo.topic()`, call `Sysinfo.query_version()` + `Sysinfo.query_config()`, set `device_state: :waiting, last_action: :initial`
- `handle_info({:usb_driver_state, :ready}, …)`:
  - If `last_action == :reboot` → auto-call `Sysinfo.query_config()`
  - Set `device_state: :ready`, clear `last_action: nil`
- `handle_info({:usb_driver_state, :disconnected}, …)` → set `device_state: :disconnected, last_action: nil`
- `handle_info({:usb_response, :version, text}, …)` → `Sysinfo.parse_version/1`, assign
- `handle_info({:usb_response, :config, text}, …)` → `Sysinfo.parse_config/1`, assign, build both forms
- `handle_event("save-wifi", params)` → choose `save_wifi_station` or `save_wifi_ap`, set `last_action: :save`
- `handle_event("save-hostname", params)` → call `Sysinfo.save_hostname/1`, set `last_action: :save`
- `handle_event("reboot", …)` → call `Sysinfo.reboot()`, set `device_state: :waiting, last_action: :reboot`

**Template layout** (same dark `bg-gray-800` card style as `FliploveLive`):

```
Header: "System Info"  [← Back to Fliplove]
        [Device status banner if device_state != :ready]
          e.g. "Rebooting… waiting for device to come back online"

Card: System             – IDF version, chip model/cores/features/revision  (read-only)
Card: Configuration      – editable hostname + [Save Hostname] button
                           rendering mode  (read-only)
                           note: "Hostname takes effect after reboot"
Card: WiFi               – mode badge (AP / Station), editable SSID + password,
                           AP mode checkbox, [Save WiFi] button
                           note: "WiFi settings take effect after reboot"
Card: RS485              – mode, address, baudrate  (read-only)
Card: Flipdot Panels     – panel count + per-panel sizes  (read-only)
Card: USB Commands       – the buttons moved from FliploveLive
                           (clear, clear inverted, wifi start, wifi stop, show tasks)
                           [Reboot] button — triggers reboot event + device_state := :rebooting
```

### `lib/fliplove_web/router.ex`

Add inside the browser scope:

```elixir
live("/sysinfo", SysinfoLive)
```

### `lib/fliplove_web/live/fliplove_live.ex`

- Remove the `<.section :if={@usb_mode?} title="USB Commands">` block and its entire content.
- Replace with a link card (only visible in USB mode):
  ```heex
  <div :if={@usb_mode?} class="bg-gray-800 p-4 rounded-lg">
    <h2 class="text-xl font-bold mb-4">USB Device</h2>
    <.link navigate={~p"/sysinfo"}
           class="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 rounded-lg inline-flex items-center gap-2">
      <.icon name="hero-cpu-chip" class="h-5 w-5" />
      System Info &amp; Commands
    </.link>
  </div>
  ```
- Remove `usb_command/1` component and `handle_event("usb-command", …)` (both move to `SysinfoLive`).

---

## Scope Boundaries

- **Editable:** WiFi (SSID, password, AP/station mode) and hostname. All other config fields (RS485, panels, rendering mode) are displayed read-only.
- No automatic polling — info is fetched once on page load, and again automatically after a reboot. A manual "Refresh" button can be added later.
- The sysinfo page is only accessible / useful in USB mode. If `FLIPLOVE_DRIVER != FLUEPDOT_USB`, the page displays a "USB not configured" message and `mount/3` returns early without subscribing or querying.
- RS485, panel layout, and rendering mode remain read-only for now.
