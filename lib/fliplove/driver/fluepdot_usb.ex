defmodule Fliplove.Driver.FluepdotUsb do
  @moduledoc """
  USB/Serial driver for Fluepdot displays.

  This GenServer driver communicates with Fluepdot displays via USB serial
  connection. It handles serial device discovery, protocol communication,
  and bitmap data transmission over UART.

  ## Configuration
  Configure via environment variables:
  - `FLIPLOVE_DEVICE` - USB device path (e.g., "/dev/ttyUSB0")

  ## Features
  - USB serial communication at 115,200 baud
  - Automatic device discovery and connection
  - Protocol handshake with command prompt detection
  - Bitmap encoding and transmission
  - Connection retry logic on failures

  ## Example
      # Set USB device path
      System.put_env("FLIPLOVE_DEVICE", "/dev/ttyUSB0")

      # Driver will automatically connect when started
  """
  alias Fliplove.Bitmap

  @doc """
  Driver for Fluepdot Display via USB
  """
  use GenServer
  require Logger

  @device_env "FLIPLOVE_DEVICE"
  @device_bitrate 115_200
  # 5 seconds between retries
  @retry_interval 5000
  # 1 second timeout for prompt
  @prompt_timeout 3000
  @prompt_regex ~r/\n(?:\e\[\d+(?:;\d+)*m)?[^\s]+>\s*(?:\e\[\d+(?:;\d+)*m)?$/

  @device_width 115
  @device_height 16

  def width, do: @device_width
  def height, do: @device_height

  defstruct [
    :counter,
    :device,
    :uart,
    :timer,
    :prompt_timer,
    :last_sent_command,
    connected: false,
    ready: false,
    buffer: "",
    log_buffer: "",
    command_queue: []
  ]

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
        Logger.debug("USB display not available (#{inspect(reason)}), retrying in #{@retry_interval}ms")
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
    cmd = "framebuf64 " <> (Bitmap.to_binary(bitmap) |> Base.encode64())

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
    new_state = %{state | connected: false, ready: false, buffer: "", log_buffer: "", command_queue: []}
    send(self(), :try_connect)
    {:noreply, new_state}
  end

  @impl true
  def handle_info({:circuits_uart, _port, "Unrecognized command" <> _rest}, state) do
    # Log the unrecognized command but don't crash
    Logger.warning("Received unrecognized command response from device")
    {:noreply, state}
  end

  @impl true
  def handle_info({:circuits_uart, _port, data}, state) when is_binary(data) do
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
        [failed_command | remaining_queue] = state.command_queue
        Logger.error("Command not recognized: #{inspect(failed_command)}")
        if state.prompt_timer, do: Process.cancel_timer(state.prompt_timer)
        {:noreply, %{state | buffer: "", log_buffer: "", command_queue: remaining_queue, ready: false}}

      Regex.match?(@prompt_regex, buffer) ->
        if state.prompt_timer, do: Process.cancel_timer(state.prompt_timer)
        # Log success of the last command if there was one
        if state.last_sent_command do
          Logger.debug("Command completed successfully: #{inspect(state.last_sent_command)}")
        end

        Logger.debug("USB prompt detected, setting ready state")
        new_state = %{state | buffer: "", log_buffer: remaining_log_buffer, ready: true, last_sent_command: nil}

        case new_state.command_queue do
          [] ->
            # No pending commands, just update state
            {:noreply, %{new_state | connected: true}}

          [next_command | remaining_queue] ->
            # Send the next command in queue
            Logger.debug("Processing next command (#{length(state.command_queue)} commands in queue)")

            case send_command(new_state, next_command) do
              {:ok, updated_state} ->
                # Remove the executed command from the queue
                {:noreply, %{updated_state | command_queue: remaining_queue}}

              error ->
                Logger.error("Failed to send command: #{inspect(error)}")
                {:noreply, new_state}
            end
        end

      true ->
        {:noreply, %{state | buffer: buffer, log_buffer: remaining_log_buffer}}
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
    case Circuits.UART.open(state.uart, state.device,
           speed: @device_bitrate,
           active: true
         ) do
      :ok ->
        Logger.info("Successfully opened serial connection to #{state.device}")
        # Rest of the initialization code...
        initial_state = %{
          state
          | connected: true,
            counter: 0,
            ready: false,
            buffer: "",
            log_buffer: ""
        }

        # Queue initialization commands...
        init_commands = [
          "wifi stop",
          "config_rendering_mode differential",
          "flipdot_clear"
        ]

        queued_state =
          Enum.reduce(init_commands, initial_state, fn cmd, acc_state ->
            Logger.debug("Queueing init command: #{cmd}")
            %{acc_state | command_queue: acc_state.command_queue ++ [cmd]}
          end)

        case Circuits.UART.write(state.uart, "\n") do
          :ok ->
            {:ok, queued_state}

          error ->
            Circuits.UART.close(state.uart)
            error
        end

      {:error, :port_timed_out} ->
        # Just close the port, keep the process
        Circuits.UART.close(state.uart)
        Logger.debug("USB port timed out while opening #{state.device}, will retry")
        {:error, :port_timed_out}

      {:error, reason} = error ->
        Circuits.UART.close(state.uart)
        Logger.debug("Unable to initialize USB connection: #{inspect(reason)}")
        error
    end
  end

  # Queue a command for execution
  defp queue_command(state, command) do
    Logger.debug("Queueing command: #{command} (#{length(state.command_queue)} commands in queue)")
    {:ok, %{state | command_queue: state.command_queue ++ [command]}}
  end

  # Actually send a command over UART
  defp send_command(state, command) do
    case Circuits.UART.write(state.uart, command <> "\n") do
      :ok ->
        Logger.debug("Command sent: #{inspect(command)}")
        timer_ref = Process.send_after(self(), :prompt_timeout, @prompt_timeout)
        # Keep the command in queue until we get confirmation and track the sent command
        {:ok, %{state | ready: false, prompt_timer: timer_ref, last_sent_command: command}}

      error ->
        error
    end
  end

  # Manages command writing with prompt-based flow control
  defp write_command(state, command) do
    cond do
      not state.connected ->
        {:error, :not_connected}

      not state.ready ->
        # Queue the command for later execution
        queue_command(state, command)

      true ->
        # Can send immediately
        case send_command(state, command) do
          {:ok, new_state} -> {:ok, new_state}
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
