defmodule Fliplove.FontTest do
  use ExUnit.Case, async: true
  alias Fliplove.Font
  alias Fliplove.Font.Parser
  alias Fliplove.Bitmap

  @test_font_path "test/support/test_font.bdf"

  describe "Font struct" do
    test "creates a font with proper structure" do
      font = %Font{
        name: "Test Font",
        properties: %{foundry: "Test", family_name: "Fixed"},
        characters: %{65 => %{name: "A", bitmap: nil}}
      }

      assert font.name == "Test Font"
      assert font.properties.foundry == "Test"
      assert font.characters[65].name == "A"
    end

    test "get_char_by_encoding returns character when found" do
      font = %Font{
        characters: %{
          65 => %{name: "A", bitmap: nil},
          66 => %{name: "B", bitmap: nil}
        }
      }

      char = Font.get_char_by_encoding(font, 65)
      assert char.name == "A"
    end

    test "get_char_by_encoding returns nil when not found" do
      font = %Font{characters: %{65 => %{name: "A", bitmap: nil}}}

      char = Font.get_char_by_encoding(font, 99)
      assert char == nil
    end

    test "get_char_by_name returns character when found" do
      font = %Font{
        characters: %{
          65 => %{name: "A", bitmap: nil},
          66 => %{name: "B", bitmap: nil}
        }
      }

      char = Font.get_char_by_name(font, "A")
      assert char.name == "A"
    end

    test "get_char_by_name returns nil when not found" do
      font = %Font{characters: %{65 => %{name: "A", bitmap: nil}}}

      char = Font.get_char_by_name(font, "Z")
      assert char == nil
    end

    test "character_count returns correct count" do
      font = %Font{
        characters: %{
          65 => %{name: "A"},
          66 => %{name: "B"},
          67 => %{name: "C"}
        }
      }

      assert Font.character_count(font) == 3
    end

    test "encodings returns list of all encodings" do
      font = %Font{
        characters: %{
          65 => %{name: "A"},
          66 => %{name: "B"},
          32 => %{name: "space"}
        }
      }

      encodings = Font.encodings(font)
      assert Enum.sort(encodings) == [32, 65, 66]
    end

    test "character_names returns sorted list of names" do
      font = %Font{
        characters: %{
          65 => %{name: "A"},
          66 => %{name: "B"},
          32 => %{name: "space"}
        }
      }

      names = Font.character_names(font)
      assert names == ["A", "B", "space"]
    end

    test "has_encoding? returns true for existing encoding" do
      font = %Font{characters: %{65 => %{name: "A"}}}
      assert Font.has_encoding?(font, 65) == true
      assert Font.has_encoding?(font, 99) == false
    end

    test "has_character? returns true for existing character" do
      font = %Font{characters: %{65 => %{name: "A"}}}
      assert Font.has_character?(font, "A") == true
      assert Font.has_character?(font, "Z") == false
    end

    test "ascii_characters returns only ASCII range characters" do
      font = %Font{
        characters: %{
          # Below ASCII printable
          31 => %{name: "control"},
          # ASCII printable start
          32 => %{name: "space"},
          # ASCII printable
          65 => %{name: "A"},
          # ASCII printable end
          126 => %{name: "tilde"},
          # Above ASCII printable
          127 => %{name: "del"},
          # Extended ASCII
          200 => %{name: "extended"}
        }
      }

      ascii_chars = Font.ascii_characters(font)
      encodings = Map.keys(ascii_chars) |> Enum.sort()
      assert encodings == [32, 65, 126]
    end

    test "metrics returns font metrics information" do
      font = %Font{
        characters: %{65 => %{name: "A"}},
        fbb_x: 8,
        fbb_y: 12,
        fbb_x_off: 0,
        fbb_y_off: -2,
        size: 10,
        xres: 75,
        yres: 75
      }

      metrics = Font.metrics(font)
      assert metrics.character_count == 1
      assert metrics.font_bounding_box.width == 8
      assert metrics.font_bounding_box.height == 12
      assert metrics.font_bounding_box.x_offset == 0
      assert metrics.font_bounding_box.y_offset == -2
      assert metrics.size == 10
      assert metrics.resolution.x == 75
      assert metrics.resolution.y == 75
    end

    test "inspect implementation shows font name" do
      font = %Font{name: "Test Font"}
      inspected = inspect(font)
      assert inspected =~ "Test Font"
    end
  end

  describe "Font.Parser" do
    test "parses test font file successfully" do
      font = Parser.parse_font(@test_font_path)

      assert %Font{} = font
      assert font.name == "-Test-Fixed-Medium-R-Normal--8-80-75-75-C-40-ISO10646-1"
      assert is_map(font.properties)
      assert is_map(font.characters)
    end

    test "parses font metadata correctly" do
      font = Parser.parse_font(@test_font_path)

      # Check version
      assert font.version == "2.1"

      # Check properties
      assert font.properties.foundry == "Test"
      assert font.properties.family_name == "Fixed"
      assert font.properties.weight_name == "Medium"
      assert font.properties.pixel_size == 8

      # Check font bounding box
      assert font.fbb_x == 4
      assert font.fbb_y == 8
      assert font.fbb_x_off == 0
      assert font.fbb_y_off == -2

      # Check size
      assert font.size == 8
      assert font.xres == 75
      assert font.yres == 75
    end

    test "parses characters correctly" do
      font = Parser.parse_font(@test_font_path)

      # Should have 3 characters
      assert map_size(font.characters) == 3

      # Check space character (encoding 32)
      space = font.characters[32]
      assert space.name == "space"
      assert space.swx0 == 640
      assert space.swy0 == 0
      assert space.dwx0 == 4
      assert space.dwy0 == 0
      assert space.bb_width == 4
      assert space.bb_height == 8
      assert %Bitmap{} = space.bitmap

      # Check A character (encoding 65)
      char_a = font.characters[65]
      assert char_a.name == "A"
      assert char_a.bb_width == 4
      assert char_a.bb_height == 8
      assert %Bitmap{} = char_a.bitmap

      # Check B character (encoding 66)
      char_b = font.characters[66]
      assert char_b.name == "B"
      assert char_b.bb_width == 4
      assert char_b.bb_height == 8
      assert %Bitmap{} = char_b.bitmap
    end

    test "creates bitmaps with correct baseline offsets" do
      font = Parser.parse_font(@test_font_path)

      # Space character has BBX 4 8 0 -2 (baseline at 0, -2)
      space = font.characters[32]
      assert space.bitmap.baseline_x == 0
      assert space.bitmap.baseline_y == -2

      # A character has BBX 4 8 1 -1 (baseline at 1, -1)
      char_a = font.characters[65]
      assert char_a.bitmap.baseline_x == 1
      assert char_a.bitmap.baseline_y == -1

      # B character has BBX 4 8 0 0 (baseline at 0, 0)
      char_b = font.characters[66]
      assert char_b.bitmap.baseline_x == 0
      assert char_b.bitmap.baseline_y == 0
    end

    test "parses bitmap data correctly" do
      font = Parser.parse_font(@test_font_path)

      # Check space character bitmap (should be all zeros)
      space = font.characters[32]
      bitmap = space.bitmap

      # Space should have no pixels set
      for x <- 0..(bitmap.width - 1), y <- 0..(bitmap.height - 1) do
        assert Bitmap.get_pixel(bitmap, {x, y}) == 0
      end

      # Check A character bitmap
      char_a = font.characters[65]
      bitmap_a = char_a.bitmap

      # A character should have specific pattern
      # Bitmap data: 60, 90, 90, F0, 90, 90, 00, 00
      # 60 = 0110 (binary) -> pixels at x=1,2
      # 90 = 1001 (binary) -> pixels at x=0,3
      # F0 = 1111 (binary) -> pixels at x=0,1,2,3

      # Test a few key pixels (remember bitmap uses bottom-left origin)
      # Row 0 (bottom): 00 -> no pixels
      assert Bitmap.get_pixel(bitmap_a, {0, 0}) == 0
      assert Bitmap.get_pixel(bitmap_a, {1, 0}) == 0
      assert Bitmap.get_pixel(bitmap_a, {2, 0}) == 0
      assert Bitmap.get_pixel(bitmap_a, {3, 0}) == 0

      # Row 7 (top): 60 -> pixels at x=1,2
      assert Bitmap.get_pixel(bitmap_a, {0, 7}) == 0
      assert Bitmap.get_pixel(bitmap_a, {1, 7}) == 1
      assert Bitmap.get_pixel(bitmap_a, {2, 7}) == 1
      assert Bitmap.get_pixel(bitmap_a, {3, 7}) == 0
    end

    test "handles hex to binary conversion correctly" do
      # Test the hex_to_bin function indirectly through parsing
      font = Parser.parse_font(@test_font_path)
      char_a = font.characters[65]

      # F0 hex should become 1111 binary (all 4 pixels set in that row)
      # This is row 4 from bottom (index 4) in the A character
      assert Bitmap.get_pixel(char_a.bitmap, {0, 4}) == 1
      assert Bitmap.get_pixel(char_a.bitmap, {1, 4}) == 1
      assert Bitmap.get_pixel(char_a.bitmap, {2, 4}) == 1
      assert Bitmap.get_pixel(char_a.bitmap, {3, 4}) == 1
    end

    test "preserves character metadata without baseline offsets" do
      font = Parser.parse_font(@test_font_path)
      char_a = font.characters[65]

      # These should be preserved in the character
      assert char_a.name == "A"
      assert char_a.swx0 == 640
      assert char_a.swy0 == 0
      assert char_a.dwx0 == 4
      assert char_a.dwy0 == 0
      assert char_a.bb_width == 4
      assert char_a.bb_height == 8

      # These should NOT be in the character (moved to bitmap)
      refute Map.has_key?(char_a, :bb_x_off)
      refute Map.has_key?(char_a, :bb_y_off)
      refute Map.has_key?(char_a, :bitmap_lines)
    end

    test "handles missing optional character properties" do
      # Create a minimal BDF with fewer properties
      minimal_bdf = """
      STARTFONT 2.1
      FONT -Minimal-Test--4-40-75-75-C-20-ISO10646-1
      SIZE 4 75 75
      FONTBOUNDINGBOX 2 4 0 0
      CHARS 1
      STARTCHAR X
      ENCODING 88
      DWIDTH 2 0
      BBX 2 4 0 0
      BITMAP
      C0
      C0
      00
      00
      ENDCHAR
      ENDFONT
      """

      # Write to temporary file
      temp_path = "test/support/minimal_font.bdf"
      File.write!(temp_path, minimal_bdf)

      try do
        font = Parser.parse_font(temp_path)
        char_x = font.characters[88]

        assert char_x.name == "X"
        assert char_x.dwx0 == 2
        assert char_x.dwy0 == 0
        assert %Bitmap{} = char_x.bitmap

        # Should not have SWIDTH properties since they weren't specified
        refute Map.has_key?(char_x, :swx0)
        refute Map.has_key?(char_x, :swy0)
      after
        File.rm(temp_path)
      end
    end

    test "handles quoted string properties" do
      # Test with a font that has quoted string properties
      quoted_bdf = """
      STARTFONT 2.1
      FONT -Test-Font--4-40-75-75-C-20-ISO10646-1
      SIZE 4 75 75
      FONTBOUNDINGBOX 2 4 0 0
      STARTPROPERTIES 2
      COPYRIGHT "Test copyright string"
      FOUNDRY "Test Foundry"
      ENDPROPERTIES
      CHARS 1
      STARTCHAR dot
      ENCODING 46
      DWIDTH 2 0
      BBX 2 4 0 0
      BITMAP
      00
      00
      C0
      00
      ENDCHAR
      ENDFONT
      """

      temp_path = "test/support/quoted_font.bdf"
      File.write!(temp_path, quoted_bdf)

      try do
        font = Parser.parse_font(temp_path)

        assert font.properties.copyright == "Test copyright string"
        assert font.properties.foundry == "Test Foundry"
      after
        File.rm(temp_path)
      end
    end

    test "handles negative numbers in properties" do
      # Test with negative baseline offsets
      negative_bdf = """
      STARTFONT 2.1
      FONT -Test-Font--4-40-75-75-C-20-ISO10646-1
      SIZE 4 75 75
      FONTBOUNDINGBOX 2 4 0 -2
      CHARS 1
      STARTCHAR comma
      ENCODING 44
      DWIDTH 2 0
      BBX 2 4 -1 -2
      BITMAP
      00
      40
      80
      00
      ENDCHAR
      ENDFONT
      """

      temp_path = "test/support/negative_font.bdf"
      File.write!(temp_path, negative_bdf)

      try do
        font = Parser.parse_font(temp_path)

        # Check font bounding box with negative offset
        assert font.fbb_y_off == -2

        # Check character with negative baseline
        comma = font.characters[44]
        assert comma.bitmap.baseline_x == -1
        assert comma.bitmap.baseline_y == -2
      after
        File.rm(temp_path)
      end
    end

    test "parses real font file correctly" do
      # Test with one of the actual font files
      real_font_path = "data/fonts/ucs-fonts/4x6.bdf"

      if File.exists?(real_font_path) do
        font = Parser.parse_font(real_font_path)

        assert %Font{} = font
        assert font.name == "-Misc-Fixed-Medium-R-Normal--6-60-75-75-C-40-ISO10646-1"
        assert font.version == "2.1"

        # Should have many characters
        assert map_size(font.characters) > 100

        # Check some basic ASCII characters exist
        # space
        assert Map.has_key?(font.characters, 32)
        # A
        assert Map.has_key?(font.characters, 65)
        # a
        assert Map.has_key?(font.characters, 97)

        # Check that bitmaps are created properly
        char_a = font.characters[65]
        assert %Bitmap{} = char_a.bitmap
        assert char_a.bitmap.width > 0
        assert char_a.bitmap.height > 0
      else
        # Skip test if font file doesn't exist
        :ok
      end
    end

    test "handles malformed BDF gracefully" do
      malformed_bdf = """
      STARTFONT 2.1
      FONT -Test-Font
      SIZE 4 75
      FONTBOUNDINGBOX 2 4
      CHARS 1
      STARTCHAR incomplete
      ENCODING 88
      BITMAP
      C0
      ENDCHAR
      ENDFONT
      """

      temp_path = "test/support/malformed_font.bdf"
      File.write!(temp_path, malformed_bdf)

      try do
        # Should raise an error for malformed BDF
        assert_raise ArgumentError, fn ->
          Parser.parse_font(temp_path)
        end
      after
        File.rm(temp_path)
      end
    end

    test "detects fonts with invalid hex bitmap data" do
      invalid_hex_bdf = """
      STARTFONT 2.1
      FONT -Test-Font--4-40-75-75-C-20-ISO10646-1
      SIZE 4 75 75
      FONTBOUNDINGBOX 2 4 0 0
      CHARS 1
      STARTCHAR bad_hex
      ENCODING 88
      DWIDTH 2 0
      BBX 2 4 0 0
      BITMAP
      GG
      ZZ
      FF
      00
      ENDCHAR
      ENDFONT
      """

      temp_path = "test/support/invalid_hex_font.bdf"
      File.write!(temp_path, invalid_hex_bdf)

      try do
        # Should fail to parse due to invalid hex characters "GG" and "ZZ"
        assert_raise ArgumentError, fn ->
          Parser.parse_font(temp_path)
        end
      after
        File.rm(temp_path)
      end
    end

    test "detects fonts with mixed valid and invalid bitmap data" do
      mixed_bdf = """
      STARTFONT 2.1
      FONT -Test-Font--4-40-75-75-C-20-ISO10646-1
      SIZE 4 75 75
      FONTBOUNDINGBOX 2 4 0 0
      CHARS 3
      STARTCHAR good_char
      ENCODING 65
      DWIDTH 2 0
      BBX 2 4 0 0
      BITMAP
      C0
      A0
      A0
      00
      ENDCHAR
      STARTCHAR bad_char
      ENCODING 66
      DWIDTH 2 0
      BBX 2 4 0 0
      BITMAP
      GG
      HH
      II
      00
      ENDCHAR
      STARTCHAR another_good_char
      ENCODING 67
      DWIDTH 2 0
      BBX 2 4 0 0
      BITMAP
      F0
      90
      90
      F0
      ENDCHAR
      ENDFONT
      """

      temp_path = "test/support/mixed_font.bdf"
      File.write!(temp_path, mixed_bdf)

      try do
        # Should fail to parse due to invalid hex characters in bad_char
        assert_raise ArgumentError, fn ->
          Parser.parse_font(temp_path)
        end
      after
        File.rm(temp_path)
      end
    end

    test "detects fonts with characters missing required bitmap fields" do
      missing_fields_bdf = """
      STARTFONT 2.1
      FONT -Test-Font--4-40-75-75-C-20-ISO10646-1
      SIZE 4 75 75
      FONTBOUNDINGBOX 2 4 0 0
      CHARS 2
      STARTCHAR no_bbx
      ENCODING 65
      DWIDTH 2 0
      BITMAP
      C0
      A0
      ENDCHAR
      STARTCHAR no_bitmap
      ENCODING 66
      DWIDTH 2 0
      BBX 2 4 0 0
      ENDCHAR
      ENDFONT
      """

      temp_path = "test/support/missing_fields_font.bdf"
      File.write!(temp_path, missing_fields_bdf)

      try do
        # Should fail to parse due to malformed character structure
        # (BITMAP without BBX is invalid BDF format)
        assert_raise ArgumentError, fn ->
          Parser.parse_font(temp_path)
        end
      after
        File.rm(temp_path)
      end
    end

    test "handles fonts with characters missing required fields" do
      missing_required_bdf = """
      STARTFONT 2.1
      FONT -Test-Font--4-40-75-75-C-20-ISO10646-1
      SIZE 4 75 75
      FONTBOUNDINGBOX 2 4 0 0
      CHARS 1
      STARTCHAR no_encoding
      DWIDTH 2 0
      BBX 2 4 0 0
      BITMAP
      C0
      A0
      ENDCHAR
      ENDFONT
      """

      temp_path = "test/support/missing_required_font.bdf"
      File.write!(temp_path, missing_required_bdf)

      try do
        # Should raise an error for missing required ENCODING field
        assert_raise ArgumentError, ~r/Character missing required ENCODING field/, fn ->
          Parser.parse_font(temp_path)
        end
      after
        File.rm(temp_path)
      end
    end

    test "detects fonts with odd-length hex strings" do
      odd_hex_bdf = """
      STARTFONT 2.1
      FONT -Test-Font--4-40-75-75-C-20-ISO10646-1
      SIZE 4 75 75
      FONTBOUNDINGBOX 2 4 0 0
      CHARS 1
      STARTCHAR odd_hex
      ENCODING 88
      DWIDTH 2 0
      BBX 2 4 0 0
      BITMAP
      F
      A0
      C
      00
      ENDCHAR
      ENDFONT
      """

      temp_path = "test/support/odd_hex_font.bdf"
      File.write!(temp_path, odd_hex_bdf)

      try do
        # Should fail to parse due to odd-length hex strings "F" and "C"
        assert_raise ArgumentError, fn ->
          Parser.parse_font(temp_path)
        end
      after
        File.rm(temp_path)
      end
    end

    test "bitmap coordinate system matches expectations" do
      font = Parser.parse_font(@test_font_path)
      char_a = font.characters[65]
      bitmap = char_a.bitmap

      # Verify that the bitmap uses bottom-left origin as expected
      # The BDF format stores bitmap data top-to-bottom, but our Bitmap
      # module uses bottom-left origin, so the parser should handle this conversion

      # A character bitmap data (top to bottom in BDF):
      # 60 = 0110 -> row 7 (top)
      # 90 = 1001 -> row 6
      # 90 = 1001 -> row 5
      # F0 = 1111 -> row 4
      # 90 = 1001 -> row 3
      # 90 = 1001 -> row 2
      # 00 = 0000 -> row 1
      # 00 = 0000 -> row 0 (bottom)

      # Test top row (y=7): should have pattern 0110
      assert Bitmap.get_pixel(bitmap, {0, 7}) == 0
      assert Bitmap.get_pixel(bitmap, {1, 7}) == 1
      assert Bitmap.get_pixel(bitmap, {2, 7}) == 1
      assert Bitmap.get_pixel(bitmap, {3, 7}) == 0

      # Test middle row with all pixels (y=4): should have pattern 1111
      assert Bitmap.get_pixel(bitmap, {0, 4}) == 1
      assert Bitmap.get_pixel(bitmap, {1, 4}) == 1
      assert Bitmap.get_pixel(bitmap, {2, 4}) == 1
      assert Bitmap.get_pixel(bitmap, {3, 4}) == 1

      # Test bottom row (y=0): should have pattern 0000
      assert Bitmap.get_pixel(bitmap, {0, 0}) == 0
      assert Bitmap.get_pixel(bitmap, {1, 0}) == 0
      assert Bitmap.get_pixel(bitmap, {2, 0}) == 0
      assert Bitmap.get_pixel(bitmap, {3, 0}) == 0
    end
  end
end
