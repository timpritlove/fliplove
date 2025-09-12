defmodule Fliplove.Driver.Flipflapflop do
  @moduledoc """
  Driver for Flipflapflop Display via USB serial interface.
  Implements one-way communication sending full frame updates.
  """
  use GenServer
  require Logger
  alias Fliplove.Bitmap

  @device_env "FLIPLOVE_DEVICE"
  @device_bitrate 115_200
  # 5 seconds between retries
  @retry_interval 5000

  # Command bytes from Python implementation
  @picture_cmd 0b10000001

  # Native device dimensions
  @device_width 112
  @device_height 16

  def width, do: @device_width
  def height, do: @device_height

  defstruct [:device, :uart, :timer, connected: false]

  def start_link(_) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  @impl GenServer
  def init(state) do
    case System.get_env(@device_env) do
      nil ->
        {:stop, "#{@device_env} environment variable not set"}

      device ->
        # Start the UART process once
        case Circuits.UART.start_link() do
          {:ok, uart} ->
            send(self(), :try_connect)
            {:ok, %{state | device: device, uart: uart}}

          {:error, reason} ->
            Logger.error("Failed to start UART process: #{inspect(reason)}")
            {:stop, reason}
        end
    end
  end

  @impl GenServer
  def handle_info(:try_connect, state) do
    case initialize_connection(state) do
      {:ok, new_state} ->
        Logger.info("Successfully initialized Flipflapflop display")
        # Send empty frame to clear display
        send_empty_frame(new_state)
        {:noreply, new_state}

      {:error, reason} ->
        Logger.debug("Flipflapflop display not available (#{inspect(reason)}), retrying in #{@retry_interval}ms")
        Process.send_after(self(), :try_connect, @retry_interval)
        {:noreply, state}
    end
  end

  @impl GenServer
  def handle_info({:display_updated, bitmap}, %{connected: true} = state) do
    case send_frame(state, bitmap) do
      {:ok, new_state} ->
        Logger.debug("Flipflapflop: Display updated")
        {:noreply, new_state}

      {:error, reason} ->
        Logger.error("Failed to write to serial port: #{inspect(reason)}")
        # If we fail to write, try reconnecting
        send(self(), :try_connect)
        {:noreply, %{state | connected: false}}
    end
  end

  def handle_info({:display_updated, _bitmap}, state) do
    # If not connected, ignore display updates
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:circuits_uart, _port, {:error, :einval}}, state) do
    Logger.info("Flipflapflop USB device physically disconnected")

    if state.uart do
      Circuits.UART.close(state.uart)
    end

    # Reset state and try reconnecting
    new_state = %{state | connected: false}
    send(self(), :try_connect)
    {:noreply, new_state}
  end

  # Handle incoming UART data (we can ignore it since it's one-way communication)
  def handle_info({:circuits_uart, port, data}, state) do
    Logger.debug("Received UART data from #{port}: #{inspect(data, base: :hex, binaries: :as_binaries)}")
    {:noreply, state}
  end

  defp initialize_connection(state) do
    # Just close the port if it's open, but keep the UART process
    if state.connected do
      Circuits.UART.close(state.uart)
    end

    case Circuits.UART.open(state.uart, state.device,
           speed: @device_bitrate,
           active: true
         ) do
      :ok ->
        Logger.info("Successfully opened serial connection to #{state.device}")
        {:ok, %{state | connected: true}}

      {:error, reason} = error ->
        Logger.debug("Failed to open port: #{inspect(reason)}")
        error
    end
  end

  defp send_empty_frame(state) do
    empty_bitmap = Bitmap.new(@device_width, @device_height)
    send_frame(state, empty_bitmap)
  end

  defp send_frame(state, bitmap) do
    # Create a new bitmap of the device's native size and place the display content in it
    device_bitmap = Bitmap.new(@device_width, @device_height)
    {width, height} = Bitmap.dimensions(bitmap)
    cropped = Bitmap.crop(bitmap, {0, 0}, width, height)

    # Overlay the cropped bitmap onto the device bitmap (left-aligned)
    device_bitmap = Bitmap.overlay(device_bitmap, cropped)

    # Pack the frame data according to the Python implementation
    frame_data = pack_frame_data(device_bitmap)

    case Circuits.UART.write(state.uart, frame_data) do
      :ok -> {:ok, state}
      error -> error
    end
  end

  defp pack_frame_data(bitmap) do
    # Start with the PICTURE command byte
    frame = <<@picture_cmd>>

    # Convert bitmap to list of bits, row by row (bottom to top)
    bits =
      for y <- (@device_height - 1)..0//-1,
          x <- 0..(@device_width - 1) do
        if Bitmap.get_pixel(bitmap, {x, y}) == 1, do: "1", else: "0"
      end

    # Join all bits into a single string
    bit_string = Enum.join(bits)

    # Split into 7-bit chunks and pack each with leading 0
    chunks =
      bit_string
      |> String.graphemes()
      |> Enum.chunk_every(7, 7, :discard)
      |> Enum.map(fn chunk ->
        # Add leading 0 and convert to byte
        ("0" <> Enum.join(chunk))
        |> String.to_integer(2)
      end)

    # Convert chunks to binary
    frame <> :binary.list_to_bin(chunks)
  end

  @impl GenServer
  def terminate(_reason, state) do
    if state.uart do
      Circuits.UART.close(state.uart)
    end
  end
end
