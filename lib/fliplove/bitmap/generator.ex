defmodule Fliplove.Bitmap.Generator do
  @moduledoc """
  Collection of functions for generating various types of bitmap patterns.
  Includes random noise, Perlin noise, gradients, and other pattern generators.
  """

  alias Fliplove.Bitmap

  @doc """
  Create a bitmap with randomly set pixels.
  """
  def random(width, height) do
    matrix =
      for x <- 0..(width - 1),
          y <- 0..(height - 1),
          into: %{},
          do: {{x, y}, Enum.random(0..1)}

    Bitmap.new(width, height, matrix)
  end

  @doc """
  Create a bitmap using Perlin noise to generate more natural-looking random patterns.
  The scale parameter determines the "zoom level" of the noise (default: 0.1).
  The threshold parameter determines the cutoff between black and white pixels (default: 0.5).

  Options:
    - scale: zoom level of the noise (default: 0.1)
    - threshold: cutoff between black and white pixels (default: 0.5)
    - octaves: number of noise layers to combine (default: 1)
    - persistence: how much each octave contributes (default: 0.5)
    - seed: random seed for the noise pattern (default: random)
  """
  def perlin_noise(width, height, opts \\ []) do
    opts = Keyword.validate!(opts,
      scale: 0.1,
      threshold: 0.5,
      octaves: 1,
      persistence: 0.5,
      seed: :erlang.system_time()
    )

    matrix =
      for x <- 0..(width - 1),
          y <- 0..(height - 1),
          into: %{} do
        # Generate noise value by combining multiple octaves
        noise_value =
          Enum.reduce(0..(opts[:octaves] - 1), 0, fn octave, acc ->
            frequency = :math.pow(2, octave)
            amplitude = :math.pow(opts[:persistence], octave)

            # Sample noise at current frequency
            nx = x * opts[:scale] * frequency
            ny = y * opts[:scale] * frequency

            # Add this octave's contribution
            acc + amplitude * noise_2d(nx, ny, opts[:seed])
          end)

        # Normalize from [-1,1] to [0,1] range and compare with threshold
        normalized_value = (noise_value + 1) / 2
        value = if normalized_value > opts[:threshold], do: 1, else: 0
        {{x, y}, value}
      end

    Bitmap.new(width, height, matrix)
  end

  @doc """
  Create a bitmap using Perlin noise with randomized parameters.
  This function automatically selects random values within sensible ranges:
    - scale: 0.05 to 0.3 (smaller = larger features)
    - octaves: 1 to 3 (more = more detail)
    - persistence: 0.3 to 0.7 (higher = more prominent detail)
    - threshold: 0.4 to 0.6 (denser around 0.5)
  """
  def random_perlin_noise(width, height) do
    perlin_noise(width, height,
      scale: :rand.uniform() * 0.25 + 0.05,        # 0.05 to 0.3
      octaves: :rand.uniform(3),                    # 1 to 3
      persistence: :rand.uniform() * 0.4 + 0.3,     # 0.3 to 0.7
      threshold: :rand.uniform() * 0.2 + 0.4        # 0.4 to 0.6 (denser around 0.5)
    )
  end

  @doc """
  Draw a gradient from left to right using randomized dithering
  """
  def gradient_h(width, height) do
    matrix =
      for x <- 0..(width - 1), y <- 0..(height - 1), into: %{} do
        value = if Enum.random(0..(width - 1)) <= x, do: 0, else: 1
        {{x, y}, value}
      end

    Bitmap.new(width, height, matrix)
  end

  @doc """
  Draw a gradient from top to bottom using randomized dithering
  """
  def gradient_v(width, height) do
    matrix =
      for y <- 0..(height - 1), x <- 0..(width - 1), into: %{} do
        value = if Enum.random(0..(height - 1)) <= y, do: 0, else: 1
        {{x, y}, value}
      end

    Bitmap.new(width, height, matrix)
  end

  # Private helper functions for Perlin noise

  # Simple 2D noise function using interpolated gradients
  defp noise_2d(x, y, seed) do
    # Get grid cell coordinates
    x0 = floor(x)
    x1 = x0 + 1
    y0 = floor(y)
    y1 = y0 + 1

    # Get interpolation weights
    sx = x - x0
    sy = y - y0

    # Generate pseudo-random gradients
    n00 = dot_grid_gradient(x0, y0, x, y, seed)
    n10 = dot_grid_gradient(x1, y0, x, y, seed)
    n01 = dot_grid_gradient(x0, y1, x, y, seed)
    n11 = dot_grid_gradient(x1, y1, x, y, seed)

    # Interpolate
    lerp(
      lerp(n00, n10, smooth(sx)),
      lerp(n01, n11, smooth(sx)),
      smooth(sy)
    )
  end

  # Generate a pseudo-random gradient vector based on coordinates
  defp dot_grid_gradient(ix, iy, x, y, seed) do
    # Generate a pseudo-random angle based on coordinates and seed
    angle = :erlang.phash2({ix, iy, seed}, 360) * :math.pi() / 180

    # Create gradient vector
    gx = :math.cos(angle)
    gy = :math.sin(angle)

    # Compute dot product with distance vector
    dx = x - ix
    dy = y - iy
    dx * gx + dy * gy
  end

  # Smooth interpolation curve
  defp smooth(t) do
    t * t * (3 - 2 * t)
  end

  # Linear interpolation
  defp lerp(a, b, t) do
    a + t * (b - a)
  end

  @doc """
  Create a bitmap using flow fields to generate organic, flowing patterns.
  The field is generated using multiple frequency components and randomized offsets
  to create more varied and interesting patterns.

  Options:
    - num_particles: number of particles to trace (default: 500)
    - steps: number of steps each particle takes (default: 50)
    - field_scale: base scale of the vector field (default: 0.05)
    - velocity: base speed of particle movement (default: 0.5)
    - complexity: number of frequency components (default: 3)
    - seed: random seed for particle placement (default: random)
  """
  def flow_field(width, height, opts \\ []) do
    opts = Keyword.validate!(opts,
      num_particles: 500,
      steps: 50,
      field_scale: 0.05,
      velocity: 0.5,
      complexity: 3,
      seed: :erlang.system_time()
    )

    :rand.seed(:exsss, {opts[:seed], 0, 0})
    matrix = %{}

    # Generate random offsets and frequencies for more varied patterns
    field_components = for _ <- 1..opts[:complexity] do
      %{
        offset_x: :rand.uniform() * width,
        offset_y: :rand.uniform() * height,
        freq_x: opts[:field_scale] * (0.5 + :rand.uniform()),
        freq_y: opts[:field_scale] * (0.5 + :rand.uniform()),
        phase: :rand.uniform() * 2 * :math.pi(),
        amplitude: 0.5 + :rand.uniform() * 0.5
      }
    end

    # Generate vector field function with multiple frequency components
    field_fn = fn x, y ->
      # Combine multiple frequency components
      {dx, dy} = Enum.reduce(field_components, {0.0, 0.0}, fn component, {acc_x, acc_y} ->
        # Calculate angle from this component
        angle = :math.sin((x + component.offset_x) * component.freq_x + component.phase) +
               :math.cos((y + component.offset_y) * component.freq_y + component.phase)

        # Add this component's contribution
        {
          acc_x + :math.cos(angle) * component.amplitude,
          acc_y + :math.sin(angle) * component.amplitude
        }
      end)

      # Normalize and scale by velocity
      magnitude = :math.sqrt(dx * dx + dy * dy)
      if magnitude > 0 do
        {
          dx / magnitude * opts[:velocity],
          dy / magnitude * opts[:velocity]
        }
      else
        {opts[:velocity], 0}
      end
    end

    # Trace particles through the field with varied starting positions
    matrix =
      Enum.reduce(1..opts[:num_particles], matrix, fn _, acc ->
        # Start particles in a more distributed way
        x = :rand.uniform() * width
        y = :rand.uniform() * height
        trace_particle(acc, field_fn, {x, y}, width, height, opts[:steps])
      end)

    Bitmap.new(width, height, matrix)
  end

  # Helper function to trace a single particle
  defp trace_particle(matrix, field_fn, {start_x, start_y}, width, height, steps) do
    Enum.reduce(1..steps, {start_x, start_y, matrix}, fn _, {x, y, acc} ->
      if x >= 0 and x < width and y >= 0 and y < height do
        # Mark the current position
        pos = {floor(x), floor(y)}
        new_acc = Map.put(acc, pos, 1)

        # Get direction from field
        {dx, dy} = field_fn.(x, y)

        # Move particle and return the updated position and accumulator
        {x + dx, y + dy, new_acc}
      else
        {x, y, acc}
      end
    end)
    |> elem(2)  # Extract the final matrix from the tuple
  end

  @doc """
  Create a bitmap using wave interference patterns, similar to ripples in water.
  Multiple wave sources are placed and their interference creates the pattern.

  Options:
    - num_sources: number of wave sources (default: 4)
    - wavelength: base wavelength of the waves (default: 12)
    - amplitude: wave amplitude (default: 0.8)
    - threshold: cutoff between black and white pixels (default: 0.4)
    - seed: random seed for source placement (default: random)
  """
  def wave_interference(width, height, opts \\ []) do
    opts = Keyword.validate!(opts,
      num_sources: 4,
      wavelength: 12,
      amplitude: 0.8,
      threshold: 0.4,
      seed: :erlang.system_time()
    )

    :rand.seed(:exsss, {opts[:seed], 0, 0})

    # Generate random wave sources with varying frequencies
    sources = for _i <- 1..opts[:num_sources] do
      # Vary wavelength slightly for each source to create more interesting patterns
      wavelength_variation = opts[:wavelength] * (0.9 + 0.2 * :rand.uniform())
      {
        :rand.uniform() * width,
        :rand.uniform() * height,
        wavelength_variation
      }
    end

    # Calculate interference pattern
    matrix =
      for x <- 0..(width - 1),
          y <- 0..(height - 1),
          into: %{} do
        # Sum waves from all sources
        value =
          Enum.reduce(sources, 0, fn {sx, sy, wavelength}, acc ->
            distance = :math.sqrt(:math.pow(x - sx, 2) + :math.pow(y - sy, 2))
            wave = :math.sin(2 * :math.pi() * distance / wavelength) * opts[:amplitude]
            acc + wave
          end)

        # Normalize and threshold
        normalized_value = (value / opts[:num_sources] + 1) / 2
        pixel = if normalized_value > opts[:threshold], do: 1, else: 0
        {{x, y}, pixel}
      end

    Bitmap.new(width, height, matrix)
  end

  @doc """
  Create a bitmap using recursive subdivision, similar to Mondrian-style patterns.
  The algorithm recursively divides the space into smaller rectangles.

  Options:
    - min_size: minimum size of subdivided rectangles (default: 8)
    - split_probability: probability of splitting a rectangle (default: 0.8)
    - fill_probability: probability of filling a rectangle with 1s (default: 0.3)
    - seed: random seed for subdivisions (default: random)
  """
  def recursive_subdivision(width, height, opts \\ []) do
    opts = Keyword.validate!(opts,
      min_size: 8,
      split_probability: 0.8,
      fill_probability: 0.3,
      seed: :erlang.system_time()
    )

    :rand.seed(:exsss, {opts[:seed], 0, 0})
    matrix = %{}

    # Start recursive subdivision with the full rectangle
    matrix = subdivide_rect(matrix, {0, 0, width - 1, height - 1}, opts)
    Bitmap.new(width, height, matrix)
  end

  # Helper function to recursively subdivide rectangles
  defp subdivide_rect(matrix, {x1, y1, x2, y2}, opts) do
    width = x2 - x1 + 1
    height = y2 - y1 + 1

    cond do
      width < opts[:min_size] or height < opts[:min_size] ->
        # Fill rectangle based on fill_probability
        value = if :rand.uniform() < opts[:fill_probability], do: 1, else: 0
        fill_rect(matrix, {x1, y1, x2, y2}, value)

      :rand.uniform() < opts[:split_probability] ->
        # Decide split direction based on aspect ratio
        if width > height do
          # Split vertically with some randomness but avoid extreme splits
          split_point = :rand.uniform() * 0.4 + 0.3  # Results in 0.3 to 0.7
          split_x = x1 + floor(width * split_point)
          matrix
          |> subdivide_rect({x1, y1, split_x, y2}, opts)
          |> subdivide_rect({split_x + 1, y1, x2, y2}, opts)
        else
          # Split horizontally with some randomness but avoid extreme splits
          split_point = :rand.uniform() * 0.4 + 0.3  # Results in 0.3 to 0.7
          split_y = y1 + floor(height * split_point)
          matrix
          |> subdivide_rect({x1, y1, x2, split_y}, opts)
          |> subdivide_rect({x1, split_y + 1, x2, y2}, opts)
        end

      true ->
        # Fill with value based on fill_probability if we don't split
        value = if :rand.uniform() < opts[:fill_probability], do: 1, else: 0
        fill_rect(matrix, {x1, y1, x2, y2}, value)
    end
  end

  # Helper function to fill a rectangle with a value
  defp fill_rect(matrix, {x1, y1, x2, y2}, value) do
    for x <- x1..x2,
        y <- y1..y2,
        into: matrix do
      {{x, y}, value}
    end
  end

  @doc """
  Create a bitmap using the Mandelbrot set, focusing on interesting regions
  that provide a good balance of filled and empty pixels.

  Options:
    - max_iter: maximum number of iterations (default: 20)
    - region: preset region to view (default: random)
      - :main - Main cardioid view
      - :spiral - Spiral arm region
      - :valley - Valley between bulbs
      - :detail - Interesting detail region
      - :random - Random selection from above
    - zoom: base zoom level (default: 1.0)
    - seed: random seed for variations (default: random)
  """
  def mandelbrot(width, height, opts \\ []) do
    opts = Keyword.validate!(opts,
      max_iter: 20,
      region: :random,
      zoom: 1.0,
      seed: :erlang.system_time()
    )

    :rand.seed(:exsss, {opts[:seed], 0, 0})

    # Define interesting regions (center_x, center_y, zoom)
    regions = %{
      main: {-0.5, 0.0, 1.5},
      spiral: {-0.744, 0.1, 0.3},
      valley: {-0.2, 0.65, 0.2},
      detail: {-1.77, 0.0, 0.08}
    }

    # Select region
    region = if opts[:region] == :random do
      Enum.random(Map.keys(regions))
    else
      opts[:region]
    end

    {center_x, center_y, region_zoom} = Map.get(regions, region)

    # Add small random variations
    center_x = center_x + (:rand.uniform() - 0.5) * region_zoom * 0.1
    center_y = center_y + (:rand.uniform() - 0.5) * region_zoom * 0.1
    zoom = region_zoom * opts[:zoom] * (0.95 + :rand.uniform() * 0.1)

    # Calculate aspect-ratio preserving scaling factors
    {scale_x, scale_y} =
      if width / height >= 1.0 do
        # Wider than tall - scale horizontal to match vertical
        sy = zoom / height
        {sy, sy}
      else
        # Taller than wide - scale vertical to match horizontal
        sx = zoom / width
        {sx, sx}
      end

    matrix =
      for x <- 0..(width - 1),
          y <- 0..(height - 1),
          into: %{} do
        # Map pixel coordinates to complex plane, maintaining aspect ratio
        c_real = (x - width / 2) * scale_x + center_x
        c_imag = (y - height / 2) * scale_y + center_y

        # Calculate if point is in set
        value =
          if in_mandelbrot_set?({c_real, c_imag}, opts[:max_iter]) do
            1
          else
            0
          end

        {{x, y}, value}
      end

    Bitmap.new(width, height, matrix)
  end

  # Helper function to determine if a point is in the Mandelbrot set
  defp in_mandelbrot_set?({c_real, c_imag}, max_iter) do
    # Use reduce instead of Stream for better control and early escape
    result = Enum.reduce_while(1..max_iter, {0.0, 0.0}, fn _i, {z_real, z_imag} ->
      # Calculate z = z^2 + c
      new_real = z_real * z_real - z_imag * z_imag + c_real
      new_imag = 2 * z_real * z_imag + c_imag

      # Check if point escapes (magnitude > 2)
      magnitude_squared = new_real * new_real + new_imag * new_imag

      if magnitude_squared > 4.0 do
        {:halt, :escaped}  # Point escapes, not in set
      else
        {:cont, {new_real, new_imag}}  # Continue iterating
      end
    end)

    # Point is in set only if it didn't escape
    result != :escaped
  end
end
