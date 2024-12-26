defmodule Flipdot.Fluepdot.USB do
  alias Flipdot.Bitmap

  @doc """
  Driver for Fluepdot Display via USB
  """
  use GenServer
  require Logger

  @device_env "FLIPDOT_DEVICE"
  @device_bitrate 115_200
  @retry_interval 5000  # 5 seconds between retries
  @prompt_timeout 3000  # 1 second timeout for prompt
  @prompt_regex ~r/\n(?:\e\[\d+(?:;\d+)*m)?[^\s]+>\s*(?:\e\[\d+(?:;\d+)*m)?$/

  defstruct [:counter, :device, :uart, :timer, :prompt_timer, :pending_command,
            connected: false, ready: false, buffer: "", log_buffer: ""]

  def start_link(_) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  # Initializes the GenServer state and begins connection process.
  # State changes:
  # - On success: Sends :try_connect message to self
  # - On failure: Stops with error if environment variable not set
  @impl true
  def init(state) do
    case System.get_env(@device_env) do
      nil ->
        {:stop, "#{@device_env} environment variable not set"}

      device ->
        send(self(), :try_connect)
        {:ok, %{state | device: device}}
    end
  end

  # Handles connection attempts to the USB device.
  # State changes:
  # - On success: Sets connected: true, sends newline to trigger initial prompt
  # - On failure: Schedules retry after interval, keeps disconnected state
  @impl true
  def handle_info(:try_connect, state) do
    case initialize_connection(state) do
      {:ok, new_state} ->
        Logger.info("Successfully initialized USB display")
        # Send initial newline to trigger prompt
        Circuits.UART.write(new_state.uart, "\n")
        timer_ref = Process.send_after(self(), :prompt_timeout, @prompt_timeout)
        {:noreply, %{new_state | prompt_timer: timer_ref}}

      {:error, reason} ->
        Logger.error("Failed to initialize USB display: #{inspect(reason)}, retrying in #{@retry_interval}ms")
        Process.send_after(self(), :try_connect, @retry_interval)
        {:noreply, state}
    end
  end

  # Handles display update requests.
  # State changes:
  # - When connected: Sends framebuf64 command, increments counter on success
  # - When disconnected: Ignores update
  # - On write failure: Triggers reconnection attempt
  @impl true
  def handle_info({:display_updated, bitmap}, %{connected: true} = state) do
    cmd = "\nframebuf64 " <> (Bitmap.to_binary(bitmap) |> Base.encode64())
    case write_command(state, cmd) do
      {:ok, new_state} ->
        counter = new_state.counter + 1
        Logger.debug("USB: Display updated (##{counter}).")
        {:noreply, %{new_state | counter: counter}}

      {:error, reason} ->
        Logger.error("Failed to write to serial port: #{inspect(reason)}")
        # If we fail to write, try reconnecting
        send(self(), :try_connect)
        {:noreply, %{state | connected: false, ready: false, buffer: "", log_buffer: ""}}
    end
  end

  def handle_info({:display_updated, _bitmap}, state) do
    # If not connected, ignore display updates
    {:noreply, state}
  end

  # Processes incoming UART data and manages command/response flow.
  # State changes:
  # - On error response: Clears buffer, marks not ready
  # - On prompt received: Clears buffer, marks ready for next command
  # - Otherwise: Accumulates data in buffer
  @impl true
  def handle_info({:circuits_uart, _port, {:error, :einval}}, state) do
    Logger.info("USB device physically disconnected")
    # Clean up the existing connection
    if state.uart do
      Circuits.UART.close(state.uart)
    end
    # Reset state and try reconnecting
    new_state = %{state | 
      connected: false, 
      ready: false, 
      buffer: "", 
      log_buffer: "",
      pending_command: nil
    }
    send(self(), :try_connect)
    {:noreply, new_state}
  end

  @impl true
  def handle_info({:circuits_uart, _port, data}, state) do
    # Add data to both buffers
    buffer = state.buffer <> data
    log_buffer = state.log_buffer <> data

    # Process log buffer for complete lines
    {lines, remaining_log_buffer} = extract_complete_lines(log_buffer)
    # Log any complete lines
    for line <- lines do
      Logger.debug("USB received: #{inspect(line, binaries: :as_strings)}")
    end
    
    cond do
      String.contains?(buffer, "Unrecognized command") ->
        Logger.error("Command not recognized: #{inspect(state.pending_command)}")
        if state.prompt_timer, do: Process.cancel_timer(state.prompt_timer)
        {:noreply, %{state | buffer: "", log_buffer: "", pending_command: nil, ready: false}}

      Regex.match?(@prompt_regex, buffer) ->
        if state.prompt_timer, do: Process.cancel_timer(state.prompt_timer)
        Logger.debug("USB prompt detected, setting ready state")
        new_state = %{state | buffer: "", log_buffer: remaining_log_buffer, ready: true, pending_command: nil}

        # If this is the first prompt after initial connection (not reconnection)
        if state.counter == 0 and not state.connected do
          case write_command(new_state, "config_rendering_mode differential") do
            {:ok, configured_state} ->
              case write_command(configured_state, "flipdot_clear") do
                {:ok, final_state} -> 
                  # Set counter to 1 to indicate initialization is complete
                  {:noreply, %{final_state | counter: 1}}
                error ->
                  Logger.error("Failed to clear display: #{inspect(error)}")
                  {:noreply, new_state}
              end
            error ->
              Logger.error("Failed to set rendering mode: #{inspect(error)}")
              {:noreply, new_state}
          end
        else
          {:noreply, new_state}
        end

      true ->
        {:noreply, %{state | buffer: buffer, log_buffer: remaining_log_buffer}}
    end
  end

  # Helper function to extract complete lines from a buffer
  defp extract_complete_lines(buffer) do
    case String.split(buffer, "\n", parts: 2) do
      [line, rest] ->
        {more_lines, remaining} = extract_complete_lines(rest)
        {[String.trim_trailing(line) | more_lines], remaining}
      [incomplete] ->
        {[], incomplete}
    end
  end

  # Handles prompt timeout events to maintain connection health.
  # State changes:
  # - When connected but not ready: Sends newline to trigger prompt
  # - Otherwise: No state change
  @impl true
  def handle_info(:prompt_timeout, state) do
    if state.connected and not state.ready do
      Logger.debug("No prompt received, sending newline")
      Circuits.UART.write(state.uart, "\n")
      timer_ref = Process.send_after(self(), :prompt_timeout, @prompt_timeout)
      {:noreply, %{state | prompt_timer: timer_ref}}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:command, command}, state) do
    case write_command(state, command) do
      {:ok, new_state} ->
        Logger.debug("USB command sent: #{command}")
        {:noreply, new_state}
      {:error, reason} ->
        Logger.error("Failed to send USB command: #{inspect(reason)}")
        {:noreply, state}
    end
  end

  # Initializes USB connection and configures display.
  # State flow:
  # 1. Opens UART connection
  # 2. Sets differential rendering mode
  # 3. Clears display
  # 4. Marks connection as ready
  #
  # Reverts all changes and returns error if any step fails.
  defp initialize_connection(state) do
    with {:ok, uart_pid} <- Circuits.UART.start_link(),
         :ok <- Circuits.UART.open(uart_pid, state.device,
                speed: @device_bitrate,
                active: true  # Changed to active mode to receive data
              ),
         _ <- Logger.info("Successfully opened serial connection to #{state.device}") do
      # Mark as connected but not ready, wait for first prompt
      initial_state = %{state |
        uart: uart_pid,
        connected: true,  # Mark as connected immediately after open
        counter: 0,
        ready: false,    # Will become ready when we get first prompt
        buffer: "",
        log_buffer: ""
      }

      # Send initial newline to trigger prompt
      case Circuits.UART.write(uart_pid, "\n") do
        :ok -> {:ok, initial_state}
        error ->
          Circuits.UART.close(uart_pid)
          error
      end
    else
      {:error, reason} = error ->
        if state.uart do
          Circuits.UART.close(state.uart)
        end
        Logger.error("Failed to initialize USB connection: #{inspect(reason)}")
        error
    end
  end

  # Manages command writing with prompt-based flow control.
  # State changes:
  # - When not connected: Returns error
  # - When not ready: Stores command as pending
  # - When ready: Sends command, sets not ready, starts prompt timeout
  defp write_command(state, command) do
    cond do
      not state.connected ->
        {:error, :not_connected}

      not state.ready ->
        Logger.debug("Device not ready, sending newline to trigger prompt")
        # Send newline to try to trigger a prompt
        Circuits.UART.write(state.uart, "\n")
        timer_ref = Process.send_after(self(), :prompt_timeout, @prompt_timeout)
        {:ok, %{state | pending_command: command, prompt_timer: timer_ref}}

      true ->
        case Circuits.UART.write(state.uart, command <> "\n") do
          :ok ->
            Logger.debug("Command sent, setting not ready: #{inspect(command)}")
            timer_ref = Process.send_after(self(), :prompt_timeout, @prompt_timeout)
            {:ok, %{state | ready: false, pending_command: command, prompt_timer: timer_ref}}
          error -> error
        end
    end
  end

  @impl true
  def terminate(_reason, state) do
    if state.uart do
      Circuits.UART.close(state.uart)
    end
  end
end
