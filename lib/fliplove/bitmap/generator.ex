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
end
