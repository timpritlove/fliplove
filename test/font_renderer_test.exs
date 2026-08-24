defmodule Fliplove.Font.RendererTest do
  use ExUnit.Case, async: true
  alias Fliplove.Font.Fonts.Emoji
  alias Fliplove.Font.Fonts.Flipdot
  alias Fliplove.Font.Fonts.FlipdotCondensed
  alias Fliplove.Font.Fonts.Invaders
  alias Fliplove.Font.Fonts.SpaceInvaders
  alias Fliplove.Font.Renderer

  # Text characters that both flipdot fonts must provide (each with its own design)
  @shared_text_codepoints [?é, ?è, ?ê, ?ë, ?ú, ?ù, ?ñ, ?ç] ++
                            [?á, ?à, ?í, ?ì, ?ó, ?ò, ?å] ++
                            [0x2013, 0x2014, 0x2212, 0x2026] ++
                            [0x2018, 0x2019, 0x201C, 0x201D, 0x201E] ++
                            [?×, ?÷, ?←, ?↑, ?→, ?↓]

  describe "Unicode and emoji rendering" do
    setup do
      {:ok, font: Flipdot.get()}
    end

    test "renders single-codepoint emoji from the font", %{font: font} do
      bitmap = Renderer.create_text(font, "❤")
      assert bitmap.width > 0
      assert Enum.any?(bitmap.matrix, fn {_pos, value} -> value == 1 end)
    end

    test "emoji with variation selector renders identically to bare codepoint", %{font: font} do
      # "❤️" is U+2764 followed by variation selector 16 (U+FE0F)
      with_selector = Renderer.create_text(font, "❤️")
      without_selector = Renderer.create_text(font, "❤")

      assert with_selector == without_selector
    end

    test "renders emoji outside the basic multilingual plane", %{font: font} do
      # 😀 is U+1F600, encoded as a surrogate pair in UTF-16 but a single codepoint here
      bitmap = Renderer.create_text(font, "😀")
      assert bitmap.width > 0
      assert Enum.any?(bitmap.matrix, fn {_pos, value} -> value == 1 end)
    end

    test "mixes ASCII text and emoji in one string", %{font: font} do
      text_only = Renderer.create_text(font, "I  U")
      with_emoji = Renderer.create_text(font, "I ❤ U")

      assert with_emoji.width > text_only.width
    end

    test "unknown emoji falls back to the default glyph", %{font: font} do
      unknown = Renderer.create_text(font, "🦄")
      fallback = Renderer.create_text(font, [0])

      assert unknown == fallback
    end

    test "complex grapheme cluster collapses to a single glyph", %{font: font} do
      # Family emoji: four codepoints joined by ZWJ - should render as one
      # fallback glyph, not as a row of boxes
      family = Renderer.create_text(font, "👨‍👩‍👧")
      fallback = Renderer.create_text(font, [0])

      assert family.width == fallback.width
    end

    test "color heart variants render like the standard heart", %{font: font} do
      heart = Renderer.create_text(font, "❤")

      color_hearts = [0x1F9E1, 0x1F49B, 0x1F49A, 0x1F499, 0x1F49C, 0x1F90E, 0x1F5A4, 0x1FA77, 0x1FA75, 0x1FA76]
      decorated_hearts = [0x1F497, 0x1F493, 0x1F496, 0x1F498, 0x1F49D, 0x1F49F]

      for codepoint <- color_hearts ++ decorated_hearts do
        assert Renderer.create_text(font, <<codepoint::utf8>>) == heart,
               "0x#{Integer.to_string(codepoint, 16)} should render like the standard heart"
      end
    end

    test "white and broken hearts have their own glyphs", %{font: font} do
      heart = Renderer.create_text(font, "❤")

      white = Renderer.create_text(font, "🤍")
      broken = Renderer.create_text(font, "💔")

      refute white == heart
      refute broken == heart
      assert white == Renderer.create_text(font, "♡")
    end

    test "heart on fire ZWJ sequence renders as its own glyph", %{font: font} do
      # ❤️‍🔥 is U+2764, VS16, ZWJ, U+1F525
      heart_on_fire = <<0x2764::utf8, 0xFE0F::utf8, 0x200D::utf8, 0x1F525::utf8>>
      burning = Renderer.create_text(font, heart_on_fire)

      assert burning == Renderer.create_text(font, [0xE010])
      refute burning == Renderer.create_text(font, "❤")
    end

    test "unknown ZWJ sequence still falls back to its first codepoint", %{font: font} do
      # ❤ joined with something we have no ligature for renders the plain heart
      sequence = <<0x2764::utf8, 0x200D::utf8, 0x1F9E1::utf8>>

      assert Renderer.create_text(font, sequence) == Renderer.create_text(font, "❤")
    end

    test "combining accents do not produce spurious fallback glyphs", %{font: font} do
      # "a" followed by combining acute accent (U+0301) is one grapheme; the
      # cluster collapses to its base letter
      composed = Renderer.create_text(font, "á")
      plain = Renderer.create_text(font, "a")

      assert composed == plain
    end
  end

  describe "font consistency between flipdot and flipdot_condensed" do
    test "both fonts contain every shared emoji glyph" do
      emoji_codepoints = Map.keys(Emoji.characters())

      for font <- [Flipdot.get(), FlipdotCondensed.get()], codepoint <- emoji_codepoints do
        assert Map.has_key?(font.characters, codepoint),
               "font #{font.name} is missing emoji codepoint #{codepoint} (0x#{Integer.to_string(codepoint, 16)})"
      end
    end

    test "both fonts contain every shared text character" do
      for font <- [Flipdot.get(), FlipdotCondensed.get()], codepoint <- @shared_text_codepoints do
        assert Map.has_key?(font.characters, codepoint),
               "font #{font.name} is missing text codepoint #{codepoint} (0x#{Integer.to_string(codepoint, 16)})"
      end
    end

    test "emoji with variation selector renders in the condensed font" do
      font = FlipdotCondensed.get()

      assert Renderer.create_text(font, "❤️") == Renderer.create_text(font, "❤")
    end

    test "font-specific characters survive the merge with shared emoji" do
      for font <- [Flipdot.get(), FlipdotCondensed.get()] do
        assert Map.has_key?(font.characters, 0)
        assert Map.has_key?(font.characters, ?A)
        assert Map.has_key?(font.characters, ?ä)
      end
    end

    test "invader sprites live at private use area codepoints in all fonts" do
      invader_codepoints = Map.keys(Invaders.characters())

      assert Enum.all?(invader_codepoints, &(&1 in 0xE000..0xF8FF))

      for font <- [Flipdot.get(), FlipdotCondensed.get(), SpaceInvaders.get()],
          codepoint <- invader_codepoints do
        assert Map.has_key?(font.characters, codepoint),
               "font #{font.name} is missing invader codepoint 0x#{Integer.to_string(codepoint, 16)}"
      end
    end

    test "accented letters are letters again, not invader sprites" do
      for font <- [Flipdot.get(), FlipdotCondensed.get()], codepoint <- [?á, ?à, ?í, ?ì, ?ó, ?ò, ?å] do
        char = font.characters[codepoint]
        # Invader sprites are 8-16 pixels wide; letter glyphs are far narrower
        assert char.bitmap.width <= 5,
               "#{font.name}: #{<<codepoint::utf8>>} looks like a sprite (width #{char.bitmap.width})"
      end
    end
  end
end
