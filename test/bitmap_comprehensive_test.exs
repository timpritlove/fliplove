defmodule BitmapComprehensiveTest do
  use ExUnit.Case
  alias Fliplove.Bitmap

  # Test fixtures
  def simple_2x2 do
    Bitmap.new(2, 2, %{{0, 0} => 1, {1, 1} => 1})
  end

  def simple_3x3 do
    Bitmap.new(3, 3, %{
      {0, 0} => 1,
      {1, 0} => 0,
      {2, 0} => 1,
      {0, 1} => 0,
      {1, 1} => 1,
      {2, 1} => 0,
      {0, 2} => 1,
      {1, 2} => 0,
      {2, 2} => 1
    })
  end

  def line_horizontal do
    Bitmap.new(5, 3, %{
      {0, 1} => 1,
      {1, 1} => 1,
      {2, 1} => 1,
      {3, 1} => 1,
      {4, 1} => 1
    })
  end

  def line_vertical do
    Bitmap.new(3, 5, %{
      {1, 0} => 1,
      {1, 1} => 1,
      {1, 2} => 1,
      {1, 3} => 1,
      {1, 4} => 1
    })
  end

  def corner_pixels do
    Bitmap.new(4, 4, %{
      # bottom-left
      {0, 0} => 1,
      # bottom-right
      {3, 0} => 1,
      # top-left
      {0, 3} => 1,
      # top-right
      {3, 3} => 1
    })
  end

  # Basic creation and structure tests
  describe "bitmap creation" do
    test "creates empty bitmap with correct dimensions" do
      bitmap = Bitmap.new(5, 3)
      assert Bitmap.width(bitmap) == 5
      assert Bitmap.height(bitmap) == 3
      assert Bitmap.dimensions(bitmap) == {5, 3}
      assert bitmap.matrix == %{}
    end

    test "creates bitmap with matrix" do
      matrix = %{{0, 0} => 1, {1, 1} => 1}
      bitmap = Bitmap.new(2, 2, matrix)
      assert bitmap.matrix == matrix
    end

    test "creates bitmap with baseline options" do
      bitmap = Bitmap.new(3, 3, baseline_x: 1, baseline_y: 2)
      assert bitmap.baseline_x == 1
      assert bitmap.baseline_y == 2
    end

    test "validates matrix values" do
      assert_raise RuntimeError, "Invalid matrix", fn ->
        # Invalid value
        Bitmap.new(2, 2, %{{0, 0} => 2})
      end
    end

    test "validates matrix coordinates" do
      assert_raise RuntimeError, "Invalid matrix", fn ->
        # Invalid coordinate
        Bitmap.new(2, 2, %{invalid: 1})
      end
    end
  end

  # Pixel manipulation tests
  describe "pixel operations" do
    test "get_pixel returns 0 for empty coordinates" do
      bitmap = Bitmap.new(3, 3)
      assert Bitmap.get_pixel(bitmap, {0, 0}) == 0
      assert Bitmap.get_pixel(bitmap, {1, 1}) == 0
      assert Bitmap.get_pixel(bitmap, {2, 2}) == 0
    end

    test "get_pixel returns correct values" do
      bitmap = simple_2x2()
      assert Bitmap.get_pixel(bitmap, {0, 0}) == 1
      assert Bitmap.get_pixel(bitmap, {1, 1}) == 1
      assert Bitmap.get_pixel(bitmap, {0, 1}) == 0
      assert Bitmap.get_pixel(bitmap, {1, 0}) == 0
    end

    test "set_pixel creates new bitmap with updated pixel" do
      bitmap = Bitmap.new(2, 2)
      updated = Bitmap.set_pixel(bitmap, {1, 1}, 1)

      # Original unchanged
      assert Bitmap.get_pixel(bitmap, {1, 1}) == 0
      # New bitmap updated
      assert Bitmap.get_pixel(updated, {1, 1}) == 1
    end

    test "toggle_pixel flips pixel values" do
      bitmap = simple_2x2()

      # Toggle set pixel to unset
      toggled = Bitmap.toggle_pixel(bitmap, {0, 0})
      assert Bitmap.get_pixel(toggled, {0, 0}) == 0

      # Toggle unset pixel to set
      toggled2 = Bitmap.toggle_pixel(bitmap, {0, 1})
      assert Bitmap.get_pixel(toggled2, {0, 1}) == 1
    end

    test "pixel operations preserve baseline" do
      bitmap = Bitmap.new(2, 2, baseline_x: 1, baseline_y: 1)
      updated = Bitmap.set_pixel(bitmap, {0, 0}, 1)
      assert updated.baseline_x == 1
      assert updated.baseline_y == 1
    end
  end

  # Coordinate system and orientation tests
  describe "coordinate system" do
    test "bottom-left is (0,0)" do
      bitmap = Bitmap.new(3, 3, %{{0, 0} => 1})
      text = Bitmap.to_text(bitmap)
      lines = String.split(text, "\n", trim: true)

      # Should be bottom line (last in text output)
      assert Enum.at(lines, -1) == "X  "
    end

    test "top-right is (width-1, height-1)" do
      bitmap = Bitmap.new(3, 3, %{{2, 2} => 1})
      text = Bitmap.to_text(bitmap)
      lines = String.split(text, "\n", trim: true)

      # Should be top line (first in text output)
      assert Enum.at(lines, 0) == "  X"
    end

    test "coordinate consistency across operations" do
      # Test that coordinates remain consistent through various operations
      original = corner_pixels()

      # Test each corner pixel position
      # bottom-left
      assert Bitmap.get_pixel(original, {0, 0}) == 1
      # bottom-right
      assert Bitmap.get_pixel(original, {3, 0}) == 1
      # top-left
      assert Bitmap.get_pixel(original, {0, 3}) == 1
      # top-right
      assert Bitmap.get_pixel(original, {3, 3}) == 1

      # After invert, corners should be 0, others should be 1
      inverted = Bitmap.invert(original)
      assert Bitmap.get_pixel(inverted, {0, 0}) == 0
      assert Bitmap.get_pixel(inverted, {3, 0}) == 0
      assert Bitmap.get_pixel(inverted, {0, 3}) == 0
      assert Bitmap.get_pixel(inverted, {3, 3}) == 0
      # center should be set
      assert Bitmap.get_pixel(inverted, {1, 1}) == 1
    end
  end

  # Bounding box tests
  describe "bounding box" do
    test "empty bitmap returns zero bounds" do
      bitmap = Bitmap.new(5, 5)
      assert Bitmap.bbox(bitmap) == {0, 0, 0, 0}
    end

    test "single pixel bbox" do
      bitmap = Bitmap.new(5, 5, %{{2, 3} => 1})
      assert Bitmap.bbox(bitmap) == {2, 3, 2, 3}
    end

    test "multiple pixels bbox" do
      bitmap = corner_pixels()
      assert Bitmap.bbox(bitmap) == {0, 0, 3, 3}
    end

    test "bbox with scattered pixels" do
      bitmap = Bitmap.new(10, 10, %{{1, 2} => 1, {7, 8} => 1, {3, 1} => 1})
      assert Bitmap.bbox(bitmap) == {1, 1, 7, 8}
    end

    test "clip removes empty space" do
      # Create bitmap with pixels only in center
      bitmap = Bitmap.new(7, 7, %{{3, 3} => 1, {3, 4} => 1, {4, 3} => 1})
      clipped = Bitmap.clip(bitmap)

      assert Bitmap.dimensions(clipped) == {2, 2}
      # was {3, 3}
      assert Bitmap.get_pixel(clipped, {0, 0}) == 1
      # was {3, 4}
      assert Bitmap.get_pixel(clipped, {0, 1}) == 1
      # was {4, 3}
      assert Bitmap.get_pixel(clipped, {1, 0}) == 1
    end
  end

  # Transformation tests
  describe "transformations" do
    test "translate moves pixels correctly" do
      bitmap = simple_2x2()
      translated = Bitmap.translate(bitmap, {1, 1})

      # Original pixels should be moved
      # Original {0, 0} moves to {1, 1} but that was already set, so it stays
      assert Bitmap.get_pixel(translated, {1, 1}) == 1
      # Original {1, 1} moves to {2, 2} but that's outside bounds, so it's lost
      # Original positions are now empty
      assert Bitmap.get_pixel(translated, {0, 0}) == 0
      # Note: translation clips to bitmap bounds, so some pixels may be lost
    end

    test "translate with negative offset" do
      bitmap = Bitmap.new(3, 3, %{{2, 2} => 1, {1, 1} => 1})
      translated = Bitmap.translate(bitmap, {-1, -1})

      # was {2, 2}
      assert Bitmap.get_pixel(translated, {1, 1}) == 1
      # was {1, 1}
      assert Bitmap.get_pixel(translated, {0, 0}) == 1
    end

    test "translate preserves dimensions" do
      bitmap = simple_3x3()
      translated = Bitmap.translate(bitmap, {2, 1})
      assert Bitmap.dimensions(translated) == Bitmap.dimensions(bitmap)
    end

    test "invert flips all pixels" do
      bitmap = simple_2x2()
      inverted = Bitmap.invert(bitmap)

      # Check that all pixels are flipped
      for x <- 0..1, y <- 0..1 do
        original_pixel = Bitmap.get_pixel(bitmap, {x, y})
        inverted_pixel = Bitmap.get_pixel(inverted, {x, y})
        assert inverted_pixel == 1 - original_pixel
      end
    end

    test "double invert returns original" do
      bitmap = simple_3x3()
      double_inverted = bitmap |> Bitmap.invert() |> Bitmap.invert()

      for x <- 0..2, y <- 0..2 do
        assert Bitmap.get_pixel(bitmap, {x, y}) == Bitmap.get_pixel(double_inverted, {x, y})
      end
    end
  end

  # Flip tests (critical for orientation changes)
  describe "flipping" do
    test "flip_horizontally mirrors across vertical axis" do
      bitmap = Bitmap.new(3, 2, %{{0, 0} => 1, {2, 1} => 1})
      flipped = Bitmap.flip_horizontally(bitmap)

      # {0, 0} should become {2, 0}
      assert Bitmap.get_pixel(flipped, {2, 0}) == 1
      assert Bitmap.get_pixel(flipped, {0, 0}) == 0

      # {2, 1} should become {0, 1}
      assert Bitmap.get_pixel(flipped, {0, 1}) == 1
      assert Bitmap.get_pixel(flipped, {2, 1}) == 0
    end

    test "flip_vertically mirrors across horizontal axis" do
      bitmap = Bitmap.new(2, 3, %{{0, 0} => 1, {1, 2} => 1})
      flipped = Bitmap.flip_vertically(bitmap)

      # {0, 0} should become {0, 2}
      assert Bitmap.get_pixel(flipped, {0, 2}) == 1
      assert Bitmap.get_pixel(flipped, {0, 0}) == 0

      # {1, 2} should become {1, 0}
      assert Bitmap.get_pixel(flipped, {1, 0}) == 1
      assert Bitmap.get_pixel(flipped, {1, 2}) == 0
    end

    test "double flip returns original" do
      bitmap = corner_pixels()

      # Horizontal double flip
      h_double = bitmap |> Bitmap.flip_horizontally() |> Bitmap.flip_horizontally()

      for x <- 0..3, y <- 0..3 do
        assert Bitmap.get_pixel(bitmap, {x, y}) == Bitmap.get_pixel(h_double, {x, y})
      end

      # Vertical double flip
      v_double = bitmap |> Bitmap.flip_vertically() |> Bitmap.flip_vertically()

      for x <- 0..3, y <- 0..3 do
        assert Bitmap.get_pixel(bitmap, {x, y}) == Bitmap.get_pixel(v_double, {x, y})
      end
    end

    test "flip preserves dimensions" do
      bitmap = Bitmap.new(5, 3, %{{1, 1} => 1})

      h_flipped = Bitmap.flip_horizontally(bitmap)
      assert Bitmap.dimensions(h_flipped) == {5, 3}

      v_flipped = Bitmap.flip_vertically(bitmap)
      assert Bitmap.dimensions(v_flipped) == {5, 3}
    end
  end

  # Rotation tests (critical for orientation)
  describe "rotation" do
    test "rotate clockwise 90 degrees" do
      # Create simple pattern to test rotation
      bitmap =
        Bitmap.new(3, 2, %{
          # bottom row
          {0, 0} => 1,
          {1, 0} => 1
        })

      rotated = Bitmap.rotate(bitmap, direction: :cw)

      # After CW rotation, dimensions should swap (3x2 becomes 2x3)
      assert Bitmap.dimensions(rotated) == {2, 3}

      # For CW rotation: rotated[x][y] gets pixel from original[width-1-y][x]
      # rotated[0][1] = original[2-1][0] = original[1][0] = 1
      assert Bitmap.get_pixel(rotated, {0, 1}) == 1
      # rotated[0][2] = original[2-2][0] = original[0][0] = 1
      assert Bitmap.get_pixel(rotated, {0, 2}) == 1
    end

    test "rotate counter-clockwise 90 degrees" do
      bitmap = Bitmap.new(2, 3, %{{0, 0} => 1, {1, 2} => 1})
      rotated = Bitmap.rotate(bitmap, direction: :ccw)

      # Dimensions swap (2x3 becomes 3x2)
      assert Bitmap.dimensions(rotated) == {3, 2}

      # For CCW rotation: new_matrix[x][y] = old_matrix[y][width-1-x]
      # Original {0, 0} -> rotated {0, 1}
      assert Bitmap.get_pixel(rotated, {0, 1}) == 1
      # Original {1, 2} -> rotated {2, 0}
      assert Bitmap.get_pixel(rotated, {2, 0}) == 1
    end

    test "four rotations return to original" do
      bitmap = Bitmap.new(3, 3, %{{0, 0} => 1, {2, 2} => 1})

      four_rotations =
        bitmap
        |> Bitmap.rotate(direction: :cw)
        |> Bitmap.rotate(direction: :cw)
        |> Bitmap.rotate(direction: :cw)
        |> Bitmap.rotate(direction: :cw)

      assert Bitmap.dimensions(bitmap) == Bitmap.dimensions(four_rotations)

      for x <- 0..2, y <- 0..2 do
        assert Bitmap.get_pixel(bitmap, {x, y}) == Bitmap.get_pixel(four_rotations, {x, y})
      end
    end

    test "rotation with non-square bitmap" do
      bitmap = Bitmap.new(4, 2, %{{0, 0} => 1, {3, 1} => 1})
      rotated = Bitmap.rotate(bitmap)

      # Dimensions should swap
      assert Bitmap.dimensions(rotated) == {2, 4}
    end
  end

  # Scale tests
  describe "scaling" do
    test "scale by 2" do
      bitmap = Bitmap.new(2, 2, %{{0, 0} => 1, {1, 1} => 1})
      scaled = Bitmap.scale(bitmap, 2)

      assert Bitmap.dimensions(scaled) == {4, 4}

      # Each original pixel should become a 2x2 block
      # {0, 0} becomes {0,0}, {0,1}, {1,0}, {1,1}
      assert Bitmap.get_pixel(scaled, {0, 0}) == 1
      assert Bitmap.get_pixel(scaled, {0, 1}) == 1
      assert Bitmap.get_pixel(scaled, {1, 0}) == 1
      assert Bitmap.get_pixel(scaled, {1, 1}) == 1

      # {1, 1} becomes {2,2}, {2,3}, {3,2}, {3,3}
      assert Bitmap.get_pixel(scaled, {2, 2}) == 1
      assert Bitmap.get_pixel(scaled, {2, 3}) == 1
      assert Bitmap.get_pixel(scaled, {3, 2}) == 1
      assert Bitmap.get_pixel(scaled, {3, 3}) == 1
    end

    test "scale by 3" do
      bitmap = Bitmap.new(1, 1, %{{0, 0} => 1})
      scaled = Bitmap.scale(bitmap, 3)

      assert Bitmap.dimensions(scaled) == {3, 3}

      # All pixels should be set
      for x <- 0..2, y <- 0..2 do
        assert Bitmap.get_pixel(scaled, {x, y}) == 1
      end
    end

    test "scale preserves pattern" do
      # Create checkerboard pattern
      bitmap = Bitmap.new(2, 2, %{{0, 0} => 1, {1, 1} => 1})
      scaled = Bitmap.scale(bitmap, 2)

      # Verify the pattern is preserved at larger scale
      # Bottom-left 2x2 block should be set
      assert Bitmap.get_pixel(scaled, {0, 0}) == 1
      assert Bitmap.get_pixel(scaled, {1, 1}) == 1
      # Top-right 2x2 block should be set
      assert Bitmap.get_pixel(scaled, {2, 2}) == 1
      assert Bitmap.get_pixel(scaled, {3, 3}) == 1
      # Other corners should be empty
      assert Bitmap.get_pixel(scaled, {0, 3}) == 0
      assert Bitmap.get_pixel(scaled, {3, 0}) == 0
    end
  end

  # Crop tests
  describe "cropping" do
    test "crop basic functionality" do
      bitmap = simple_3x3()
      cropped = Bitmap.crop(bitmap, {1, 1}, 2, 2)

      assert Bitmap.dimensions(cropped) == {2, 2}
      # Should contain the center 2x2 portion
      assert Bitmap.get_pixel(cropped, {0, 0}) == Bitmap.get_pixel(bitmap, {1, 1})
      assert Bitmap.get_pixel(cropped, {1, 1}) == Bitmap.get_pixel(bitmap, {2, 2})
    end

    test "crop at boundaries" do
      bitmap = corner_pixels()

      # Crop bottom-left corner
      bl_crop = Bitmap.crop(bitmap, {0, 0}, 2, 2)
      assert Bitmap.get_pixel(bl_crop, {0, 0}) == 1
      assert Bitmap.get_pixel(bl_crop, {1, 1}) == 0

      # Crop top-right corner
      tr_crop = Bitmap.crop(bitmap, {2, 2}, 2, 2)
      assert Bitmap.get_pixel(tr_crop, {1, 1}) == 1
      assert Bitmap.get_pixel(tr_crop, {0, 0}) == 0
    end

    test "crop outside bounds returns empty pixels" do
      bitmap = Bitmap.new(3, 3, %{{1, 1} => 1})
      cropped = Bitmap.crop(bitmap, {5, 5}, 2, 2)

      assert Bitmap.dimensions(cropped) == {2, 2}
      # All pixels should be 0 since crop is outside bounds
      for x <- 0..1, y <- 0..1 do
        assert Bitmap.get_pixel(cropped, {x, y}) == 0
      end
    end

    test "crop_relative positioning" do
      # center pixel
      bitmap = Bitmap.new(5, 5, %{{2, 2} => 1})

      # Crop 3x3 from center
      center_crop = Bitmap.crop_relative(bitmap, 3, 3, rel_x: :center, rel_y: :middle)
      assert Bitmap.dimensions(center_crop) == {3, 3}
      # center of crop
      assert Bitmap.get_pixel(center_crop, {1, 1}) == 1

      # Crop 3x3 from top-left
      tl_crop = Bitmap.crop_relative(bitmap, 3, 3, rel_x: :left, rel_y: :top)
      # original center pixel
      assert Bitmap.get_pixel(tl_crop, {2, 0}) == 1
    end
  end

  # Line drawing tests
  describe "line drawing" do
    test "horizontal line" do
      bitmap = Bitmap.new(5, 3)
      lined = Bitmap.line(bitmap, {0, 1}, {4, 1})

      for x <- 0..4 do
        assert Bitmap.get_pixel(lined, {x, 1}) == 1
      end

      # Other rows should be empty
      for x <- 0..4 do
        assert Bitmap.get_pixel(lined, {x, 0}) == 0
        assert Bitmap.get_pixel(lined, {x, 2}) == 0
      end
    end

    test "vertical line" do
      bitmap = Bitmap.new(3, 5)
      lined = Bitmap.line(bitmap, {1, 0}, {1, 4})

      for y <- 0..4 do
        assert Bitmap.get_pixel(lined, {1, y}) == 1
      end

      # Other columns should be empty
      for y <- 0..4 do
        assert Bitmap.get_pixel(lined, {0, y}) == 0
        assert Bitmap.get_pixel(lined, {2, y}) == 0
      end
    end

    test "diagonal line" do
      bitmap = Bitmap.new(5, 5)
      lined = Bitmap.line(bitmap, {0, 0}, {4, 4})

      # Diagonal pixels should be set
      for i <- 0..4 do
        assert Bitmap.get_pixel(lined, {i, i}) == 1
      end
    end

    test "line with negative slope" do
      bitmap = Bitmap.new(5, 5)
      lined = Bitmap.line(bitmap, {0, 4}, {4, 0})

      # Anti-diagonal pixels should be set
      for i <- 0..4 do
        assert Bitmap.get_pixel(lined, {i, 4 - i}) == 1
      end
    end
  end

  # Fill tests
  describe "fill operation" do
    test "fill empty area" do
      # Create a frame and fill the inside
      bitmap = Bitmap.frame(5, 5)
      # Fill center
      filled = Bitmap.fill(bitmap, {2, 2})

      # Center should be filled
      assert Bitmap.get_pixel(filled, {2, 2}) == 1
      assert Bitmap.get_pixel(filled, {1, 1}) == 1
      assert Bitmap.get_pixel(filled, {3, 3}) == 1

      # Frame should still be there
      assert Bitmap.get_pixel(filled, {0, 0}) == 1
      assert Bitmap.get_pixel(filled, {4, 4}) == 1
    end

    test "fill stops at boundaries" do
      # Create vertical line to separate areas
      bitmap =
        Bitmap.new(5, 3)
        |> Bitmap.line({2, 0}, {2, 2})

      # Fill left side
      filled = Bitmap.fill(bitmap, {0, 1})

      # Left side should be filled
      assert Bitmap.get_pixel(filled, {0, 1}) == 1
      assert Bitmap.get_pixel(filled, {1, 1}) == 1

      # Right side should be empty
      assert Bitmap.get_pixel(filled, {3, 1}) == 0
      assert Bitmap.get_pixel(filled, {4, 1}) == 0

      # Boundary line should remain
      assert Bitmap.get_pixel(filled, {2, 1}) == 1
    end

    test "fill already filled area does nothing" do
      bitmap = Bitmap.new(3, 3, %{{1, 1} => 1})
      filled = Bitmap.fill(bitmap, {1, 1})

      # Should be unchanged
      assert Bitmap.get_pixel(filled, {1, 1}) == 1
      assert Bitmap.get_pixel(filled, {0, 0}) == 0
    end
  end

  # Overlay tests
  describe "overlay operations" do
    test "basic overlay" do
      base = Bitmap.new(5, 5)
      overlay = Bitmap.new(3, 3, %{{1, 1} => 1})

      result = Bitmap.overlay(base, overlay, cursor_x: 1, cursor_y: 1)

      # overlay center at base (1,1) + overlay (1,1)
      assert Bitmap.get_pixel(result, {2, 2}) == 1
      assert Bitmap.dimensions(result) == {5, 5}
    end

    test "overlay with opaque option" do
      # Base has center pixel
      base = Bitmap.new(3, 3, %{{1, 1} => 1})
      # Overlay has corner pixel
      overlay = Bitmap.new(3, 3, %{{0, 0} => 1})

      # Non-opaque overlay (default)
      result1 = Bitmap.overlay(base, overlay, opaque: false)
      # Base pixel preserved
      assert Bitmap.get_pixel(result1, {1, 1}) == 1
      # Overlay pixel added
      assert Bitmap.get_pixel(result1, {0, 0}) == 1

      # Opaque overlay
      result2 = Bitmap.overlay(base, overlay, opaque: true)
      # Base pixel cleared by overlay
      assert Bitmap.get_pixel(result2, {1, 1}) == 0
      # Overlay pixel added
      assert Bitmap.get_pixel(result2, {0, 0}) == 1
    end

    test "overlay clipping" do
      base = Bitmap.new(3, 3)
      overlay = Bitmap.new(3, 3, %{{0, 0} => 1, {1, 1} => 1, {2, 2} => 1})

      # Overlay positioned partially outside base
      result = Bitmap.overlay(base, overlay, cursor_x: 2, cursor_y: 2)

      # Only the overlapping part should be visible
      # overlay (0,0) at base (2,2)
      assert Bitmap.get_pixel(result, {2, 2}) == 1
      # Other overlay pixels are outside base bounds
    end
  end

  # Merge tests
  describe "merge operations" do
    test "merge two bitmaps" do
      bitmap1 = Bitmap.new(3, 3, %{{0, 0} => 1, {1, 1} => 1})
      bitmap2 = Bitmap.new(3, 3, %{{2, 2} => 1, {1, 0} => 1})

      merged = Bitmap.merge(bitmap1, bitmap2)

      # All pixels from both bitmaps should be present
      assert Bitmap.get_pixel(merged, {0, 0}) == 1
      assert Bitmap.get_pixel(merged, {1, 1}) == 1
      assert Bitmap.get_pixel(merged, {2, 2}) == 1
      assert Bitmap.get_pixel(merged, {1, 0}) == 1
    end

    test "merge with offset" do
      bitmap1 = Bitmap.new(2, 2, %{{0, 0} => 1})
      bitmap2 = Bitmap.new(2, 2, %{{0, 0} => 1})

      merged = Bitmap.merge(bitmap1, bitmap2, offset_x: 2, offset_y: 1)

      # from bitmap1
      assert Bitmap.get_pixel(merged, {0, 0}) == 1
      # from bitmap2 with offset
      assert Bitmap.get_pixel(merged, {2, 1}) == 1
    end

    test "merge empty bitmaps" do
      bitmap1 = Bitmap.new(3, 3, %{{1, 1} => 1})
      # empty
      bitmap2 = Bitmap.new(3, 3)

      merged1 = Bitmap.merge(bitmap1, bitmap2)
      merged2 = Bitmap.merge(bitmap2, bitmap1)

      # Both should equal bitmap1
      assert Bitmap.get_pixel(merged1, {1, 1}) == 1
      assert Bitmap.get_pixel(merged2, {1, 1}) == 1
    end
  end

  # Text conversion tests
  describe "text conversion" do
    test "to_text with default characters" do
      bitmap = Bitmap.new(3, 2, %{{0, 0} => 1, {2, 1} => 1})
      text = Bitmap.to_text(bitmap)

      lines = String.split(text, "\n", trim: true)
      assert length(lines) == 2
      # top line
      assert Enum.at(lines, 0) == "  X"
      # bottom line
      assert Enum.at(lines, 1) == "X  "
    end

    test "to_text with custom characters" do
      bitmap = Bitmap.new(2, 2, %{{0, 0} => 1, {1, 1} => 1})
      text = Bitmap.to_text(bitmap, on: ?#, off: ?.)

      lines = String.split(text, "\n", trim: true)
      # top line
      assert Enum.at(lines, 0) == ".#"
      # bottom line
      assert Enum.at(lines, 1) == "#."
    end

    test "from_string creates correct bitmap" do
      text = "X.X\n.X.\nX.X"
      bitmap = Bitmap.from_string(text, on: [?X], off: [?.])

      assert Bitmap.dimensions(bitmap) == {3, 3}
      # Check corner pixels (remember Y is flipped in text)
      # top-left in text = {0, 2} in bitmap
      assert Bitmap.get_pixel(bitmap, {0, 2}) == 1
      # top-right in text = {2, 2} in bitmap
      assert Bitmap.get_pixel(bitmap, {2, 2}) == 1
      # bottom-left in text = {0, 0} in bitmap
      assert Bitmap.get_pixel(bitmap, {0, 0}) == 1
      # bottom-right in text = {2, 0} in bitmap
      assert Bitmap.get_pixel(bitmap, {2, 0}) == 1
      # center
      assert Bitmap.get_pixel(bitmap, {1, 1}) == 1
    end

    test "from_lines_of_text with mixed input types" do
      # Test with both strings and charlists
      lines = ["X.X", '.X.', "X.X"]
      bitmap = Bitmap.from_lines_of_text(lines, on: [?X], off: [?.])

      assert Bitmap.dimensions(bitmap) == {3, 3}
      # center
      assert Bitmap.get_pixel(bitmap, {1, 1}) == 1
    end

    test "text round-trip consistency" do
      original = simple_3x3()
      text = Bitmap.to_text(original)
      reconstructed = Bitmap.from_string(text)

      assert Bitmap.dimensions(original) == Bitmap.dimensions(reconstructed)

      for x <- 0..2, y <- 0..2 do
        assert Bitmap.get_pixel(original, {x, y}) == Bitmap.get_pixel(reconstructed, {x, y})
      end
    end
  end

  # Binary conversion tests
  describe "binary conversion" do
    test "to_binary and from_binary round trip" do
      # Create bitmap with height multiple of 8
      bitmap =
        Bitmap.new(3, 8, %{
          {0, 0} => 1,
          {1, 1} => 1,
          {2, 2} => 1,
          {0, 7} => 1,
          {1, 6} => 1,
          {2, 5} => 1
        })

      binary = Bitmap.to_binary(bitmap)
      reconstructed = Bitmap.from_binary(binary, 3, 8)

      assert Bitmap.dimensions(bitmap) == Bitmap.dimensions(reconstructed)

      for x <- 0..2, y <- 0..7 do
        assert Bitmap.get_pixel(bitmap, {x, y}) == Bitmap.get_pixel(reconstructed, {x, y})
      end
    end

    test "to_binary requires height multiple of 8" do
      # Height not multiple of 8
      bitmap = Bitmap.new(3, 7)

      assert_raise RuntimeError, ~r/height.*not a multiple of 8/, fn ->
        Bitmap.to_binary(bitmap)
      end
    end

    test "from_binary validates data size" do
      # 3 bytes = 24 bits
      data = <<1, 2, 3>>

      # Should work for 3x8 (24 pixels)
      bitmap = Bitmap.from_binary(data, 3, 8)
      assert Bitmap.dimensions(bitmap) == {3, 8}

      # Should fail for mismatched dimensions
      assert_raise RuntimeError, ~r/Packet size.*does not match dimensions/, fn ->
        # 32 pixels needed, only 24 available
        Bitmap.from_binary(data, 4, 8)
      end
    end
  end

  # Baseline tests (important for coordinate system changes)
  describe "baseline functionality" do
    test "baseline affects inspect output" do
      bitmap1 = Bitmap.new(3, 3, baseline_x: 0, baseline_y: 0)
      bitmap2 = Bitmap.new(3, 3, baseline_x: 1, baseline_y: 1)

      inspect1 = inspect(bitmap1)
      inspect2 = inspect(bitmap2)

      # Different baselines should produce different inspect outputs
      refute inspect1 == inspect2

      # Both should contain baseline markers (+)
      assert String.contains?(inspect1, "+")
      assert String.contains?(inspect2, "+")
    end

    test "baseline preserved through operations" do
      bitmap = Bitmap.new(3, 3, %{{1, 1} => 1}, baseline_x: 1, baseline_y: 2)

      # Test various operations preserve baseline
      operations = [
        &Bitmap.set_pixel(&1, {0, 0}, 1),
        &Bitmap.toggle_pixel(&1, {2, 2}),
        &Bitmap.invert/1,
        &Bitmap.translate(&1, {1, 0})
      ]

      for operation <- operations do
        result = operation.(bitmap)
        assert result.baseline_x == bitmap.baseline_x
        assert result.baseline_y == bitmap.baseline_y
      end
    end

    test "baseline in merge operations" do
      bitmap1 = Bitmap.new(3, 3, %{{0, 0} => 1}, baseline_x: 1, baseline_y: 1)
      bitmap2 = Bitmap.new(3, 3, %{{2, 2} => 1}, baseline_x: 2, baseline_y: 2)

      # Normal merge should normalize coordinates
      merged_normal = Bitmap.merge(bitmap1, bitmap2)
      assert merged_normal.baseline_x == 0
      assert merged_normal.baseline_y == 0

      # Preserve baseline merge should keep bitmap1's baseline
      merged_preserve = Bitmap.merge(bitmap1, bitmap2, preserve_baseline: true)
      assert merged_preserve.baseline_x == bitmap1.baseline_x
      assert merged_preserve.baseline_y == bitmap1.baseline_y
    end
  end

  # Utility function tests
  describe "utility functions" do
    test "diff_count compares bitmaps" do
      bitmap1 = simple_2x2()
      bitmap2 = Bitmap.invert(bitmap1)

      # All 4 pixels should be different
      assert Bitmap.diff_count(bitmap1, bitmap2) == 4

      # Same bitmap should have 0 differences
      assert Bitmap.diff_count(bitmap1, bitmap1) == 0
    end

    test "diff_count requires same dimensions" do
      bitmap1 = Bitmap.new(2, 2)
      bitmap2 = Bitmap.new(3, 3)

      assert_raise RuntimeError, "Bitmaps must have the same dimensions", fn ->
        Bitmap.diff_count(bitmap1, bitmap2)
      end
    end

    test "normalize adjusts coordinates" do
      # Create bitmap with pixels at negative coordinates (simulated)
      bitmap = %Fliplove.Bitmap{
        width: 5,
        height: 5,
        matrix: %{{-1, -1} => 1, {2, 3} => 1},
        baseline_x: 0,
        baseline_y: 0
      }

      normalized = Bitmap.normalize(bitmap)

      # Coordinates should be shifted to start at 0,0
      # was {-1, -1}
      assert Bitmap.get_pixel(normalized, {0, 0}) == 1
      # was {2, 3}
      assert Bitmap.get_pixel(normalized, {3, 4}) == 1

      # Baseline should be adjusted
      # 0 + (-1)
      assert normalized.baseline_x == -1
      # 0 + (-1)
      assert normalized.baseline_y == -1
    end

    test "random creates bitmap with random pixels" do
      bitmap = Bitmap.random(5, 5)

      assert Bitmap.dimensions(bitmap) == {5, 5}

      # Should have some pixels set (very unlikely to be all 0 or all 1)
      pixel_count =
        for x <- 0..4, y <- 0..4, reduce: 0 do
          acc -> acc + Bitmap.get_pixel(bitmap, {x, y})
        end

      # With 25 pixels, extremely unlikely to be 0 or 25
      assert pixel_count > 0
      assert pixel_count < 25
    end

    test "frame creates border" do
      bitmap = Bitmap.frame(4, 4)

      # Corners should be set
      assert Bitmap.get_pixel(bitmap, {0, 0}) == 1
      assert Bitmap.get_pixel(bitmap, {3, 0}) == 1
      assert Bitmap.get_pixel(bitmap, {0, 3}) == 1
      assert Bitmap.get_pixel(bitmap, {3, 3}) == 1

      # Edges should be set
      # bottom edge
      assert Bitmap.get_pixel(bitmap, {1, 0}) == 1
      # top edge
      assert Bitmap.get_pixel(bitmap, {1, 3}) == 1
      # left edge
      assert Bitmap.get_pixel(bitmap, {0, 1}) == 1
      # right edge
      assert Bitmap.get_pixel(bitmap, {3, 1}) == 1

      # Interior should be empty
      assert Bitmap.get_pixel(bitmap, {1, 1}) == 0
      assert Bitmap.get_pixel(bitmap, {2, 2}) == 0
    end
  end

  # Edge cases and error conditions
  describe "edge cases" do
    test "operations on empty bitmaps" do
      empty = Bitmap.new(0, 0)

      # These should not crash
      assert Bitmap.bbox(empty) == {0, 0, 0, 0}
      assert Bitmap.invert(empty).matrix == %{}
    end

    test "operations on single pixel bitmaps" do
      single = Bitmap.new(1, 1, %{{0, 0} => 1})

      # All operations should work
      assert Bitmap.flip_horizontally(single) == single
      assert Bitmap.flip_vertically(single) == single
      assert Bitmap.get_pixel(Bitmap.invert(single), {0, 0}) == 0
    end

    test "large coordinate values" do
      # Test with large but valid coordinates
      large_bitmap = Bitmap.new(1000, 1000)
      updated = Bitmap.set_pixel(large_bitmap, {999, 999}, 1)

      assert Bitmap.get_pixel(updated, {999, 999}) == 1
      assert Bitmap.bbox(updated) == {999, 999, 999, 999}
    end

    test "boundary coordinate access" do
      bitmap = Bitmap.new(3, 3, %{{0, 0} => 1, {2, 2} => 1})

      # Valid boundary coordinates
      assert Bitmap.get_pixel(bitmap, {0, 0}) == 1
      assert Bitmap.get_pixel(bitmap, {2, 2}) == 1

      # Invalid coordinates should return 0 (not crash)
      assert Bitmap.get_pixel(bitmap, {-1, -1}) == 0
      assert Bitmap.get_pixel(bitmap, {3, 3}) == 0
      assert Bitmap.get_pixel(bitmap, {100, 100}) == 0
    end
  end
end
