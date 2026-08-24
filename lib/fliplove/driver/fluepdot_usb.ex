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
  - Priority command queue: sysinfo queries jump ahead of display frames
  - PubSub broadcasts for query responses and driver state changes

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
  # 3 seconds between prompt nudges
  @prompt_timeout 3000
  # After this many consecutive nudges without a prompt, close and reopen (covers ~60 s, well beyond reboot time)
  @max_prompt_retries 20
  @prompt_regex ~r/\n(?:\e\[\d+(?:;\d+)*m)?[^\s]+>\s*(?:\e\[\d+(?:;\d+)*m)?$/
  @pubsub_topic "usb_responses"

  @device_width 115
  @device_height 16

  def width, do: @device_width
  def height, do: @device_height

  @doc "PubSub topic for driver state and query response messages."
  def topic, do: @pubsub_topic

  defstruct [
    :counter,
    :device,
    :uart,
    :timer,
    :prompt_timer,
    # nil | {:display} | {:query, tag}
    :last_sent,
    connected: false,
    ready: false,
    prompt_retries: 0,
    buffer: "",
    log_buffer: "",
    # entries are {:display, cmd} | {:query, cmd, tag}
    command_queue: []
  ]

  def start_link(_) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  # Public API

  @doc """
  Queue a query command with priority (prepended to the front of the queue).

  When the device responds the text between the command echo and the next prompt
  is broadcast as `{:usb_response, tag, text}` on `topic/0`.
  """
  def query(command, tag) do
    GenServer.cast(__MODULE__, {:query_command, command, tag})
  end

  @doc """
  Prepend a sequence of tagged command tuples atomically to the front of the queue.

  Each entry must be `{:display, cmd}` or `{:query, cmd, tag}`.
  Used by `Fliplove.Sysinfo` for multi-step save flows.
  """
  def command_sequence(commands) when is_list(commands) do
    GenServer.cast(__MODULE__, {:command_sequence, commands})
  end

  # Initializes the GenServer state and begins connection process.
  # State changes:
  # - On success: Sends :try_connect message to self
  # - On failure: Stops with error if environment variable not set
  #
  # The UART process itself is started lazily by initialize_connection/1, so a
  # momentarily unavailable port binary does not prevent the driver from
  # starting. We trap exits so that a UART crash in the window between
  # start_link and unlink cannot take the driver down.
  @impl GenServer
  def init(state) do
    case System.get_env(@device_env) do
      nil ->
        {:stop, "#{@device_env} environment variable not set"}

      device ->
        Process.flag(:trap_exit, true)
        send(self(), :try_connect)
        {:ok, %{state | device: device}}
    end
  end

  # Handles connection attempts to the USB device.
  # State changes:
  # - On success: Sets connected: true, sends newline to trigger initial prompt
  # - On failure: Schedules retry after interval, keeps disconnected state
  @impl GenServer
  def handle_info(:try_connect, state) do
    case initialize_connection(state) do
      {:ok, new_state} ->
        Logger.info("USB serial port opened, waiting for device prompt")

        case uart_write(new_state.uart, "\n") do
          :ok ->
            timer_ref = Process.send_after(self(), :prompt_timeout, @prompt_timeout)
            {:noreply, %{new_state | prompt_timer: timer_ref}}

          {:error, reason} ->
            Logger.debug("USB newline after open failed (#{inspect(reason)}), retrying connection")
            safe_close(new_state.uart)
            Process.send_after(self(), :try_connect, @retry_interval)
            {:noreply, disconnected_state(new_state)}
        end

      {:error, reason} ->
        Logger.debug("USB display not available (#{inspect(reason)}), retrying in #{@retry_interval}ms")
        Process.send_after(self(), :try_connect, @retry_interval)
        {:noreply, disconnected_state(state)}
    end
  end

  # Handles display update requests.
  # State changes:
  # - When connected: Enqueues framebuf64 command (display-priority, appended to back)
  # - When disconnected: Ignores update
  # - On write failure: Triggers reconnection attempt
  @impl GenServer
  def handle_info({:display_updated, bitmap}, %{connected: true} = state) do
    cmd = "framebuf64 " <> (Bitmap.to_binary(bitmap) |> Base.encode64())

    case write_display_command(state, cmd) do
      {:ok, new_state} ->
        counter = new_state.counter + 1
        Logger.debug("USB: Display updated (##{counter}).")
        {:noreply, %{new_state | counter: counter}}

      {:error, reason} ->
        Logger.error("Failed to write to serial port: #{inspect(reason)}")
        send(self(), :try_connect)
        {:noreply, %{state | connected: false, ready: false, buffer: "", log_buffer: ""}}
    end
  end

  def handle_info({:display_updated, _bitmap}, state) do
    {:noreply, state}
  end

  # Processes incoming UART data and manages command/response flow.
  # State changes:
  # - On error response: Clears buffer, marks not ready
  # - On prompt received: Broadcasts response (if query), broadcasts :ready, dispatches next queued command
  # - Otherwise: Accumulates data in buffer
  @impl GenServer
  def handle_info({:circuits_uart, _port, {:error, reason}}, state) do
    Logger.info("USB device disconnected (#{inspect(reason)})")

    safe_close(state.uart)

    Phoenix.PubSub.broadcast(Fliplove.PubSub, @pubsub_topic, {:usb_driver_state, :disconnected})

    send(self(), :try_connect)
    {:noreply, disconnected_state(state)}
  end

  # We trap exits (see init/1) so that a UART crash between start_link and
  # unlink cannot take the driver down. Such an exit arrives here as a message;
  # the reconnect logic is driven by write failures and UART error messages,
  # so we only log it.
  @impl GenServer
  def handle_info({:EXIT, _pid, reason}, state) do
    Logger.debug("Linked process exited: #{inspect(reason)}")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:circuits_uart, _port, "Unrecognized command" <> _rest}, state) do
    Logger.warning("Received unrecognized command response from device")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:circuits_uart, _port, data}, state) when is_binary(data) do
    buffer = state.buffer <> data
    log_buffer = state.log_buffer <> data

    {lines, remaining_log_buffer} = extract_complete_lines(log_buffer)

    for line <- lines do
      Logger.debug("USB received: #{inspect(line, binaries: :as_strings)}")
    end

    cond do
      String.contains?(buffer, "Unrecognized command") ->
        Logger.error("Command not recognized, last sent: #{inspect(state.last_sent)}")
        if state.prompt_timer, do: Process.cancel_timer(state.prompt_timer)
        {:noreply, %{state | buffer: "", log_buffer: "", ready: false, last_sent: nil}}

      Regex.match?(@prompt_regex, buffer) ->
        if state.prompt_timer, do: Process.cancel_timer(state.prompt_timer)

        case state.last_sent do
          {:query, tag} ->
            response = extract_query_response(buffer)
            Logger.debug("Query #{inspect(tag)} completed, broadcasting response")
            Phoenix.PubSub.broadcast(Fliplove.PubSub, @pubsub_topic, {:usb_response, tag, response})

          _ ->
            if state.last_sent do
              Logger.debug("Command completed successfully: #{inspect(state.last_sent)}")
            end
        end

        Phoenix.PubSub.broadcast(Fliplove.PubSub, @pubsub_topic, {:usb_driver_state, :ready})

        if state.connected do
          Logger.debug("USB prompt detected, device ready")
        else
          Logger.info("USB device ready (first prompt received)")
        end

        new_state = %{
          state
          | buffer: "",
            log_buffer: remaining_log_buffer,
            ready: true,
            last_sent: nil,
            prompt_retries: 0
        }

        case new_state.command_queue do
          [] ->
            {:noreply, %{new_state | connected: true}}

          [next_command | remaining_queue] ->
            Logger.debug("Processing next command (#{length(state.command_queue)} commands in queue)")

            case send_command(new_state, next_command) do
              {:ok, updated_state} ->
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
  # - When connected but not ready: Sends newline to nudge the device, increments retry counter
  # - After @max_prompt_retries consecutive nudges: closes port and re-enters try_connect loop
  # - Otherwise: No state change
  @impl GenServer
  def handle_info(:prompt_timeout, %{connected: true, ready: false} = state) do
    retries = state.prompt_retries + 1

    if retries >= @max_prompt_retries do
      Logger.warning(
        "No prompt received after #{retries} attempts (~#{div(retries * @prompt_timeout, 1000)} s), " <>
          "closing USB serial port and retrying connection"
      )

      safe_close(state.uart)

      Phoenix.PubSub.broadcast(Fliplove.PubSub, @pubsub_topic, {:usb_driver_state, :disconnected})

      Process.send_after(self(), :try_connect, @retry_interval)
      {:noreply, disconnected_state(state)}
    else
      Logger.debug("No prompt received (attempt #{retries}/#{@max_prompt_retries}), sending newline")

      case uart_write(state.uart, "\n") do
        :ok ->
          timer_ref = Process.send_after(self(), :prompt_timeout, @prompt_timeout)
          {:noreply, %{state | prompt_timer: timer_ref, prompt_retries: retries}}

        {:error, reason} ->
          Logger.debug("USB prompt nudge failed (#{inspect(reason)}), retrying connection")
          safe_close(state.uart)
          Process.send_after(self(), :try_connect, @retry_interval)
          {:noreply, disconnected_state(state)}
      end
    end
  end

  def handle_info(:prompt_timeout, state) do
    {:noreply, state}
  end

  defp extract_complete_lines(buffer) do
    case String.split(buffer, "\n", parts: 2) do
      [line, rest] ->
        {more_lines, remaining} = extract_complete_lines(rest)
        {[String.trim_trailing(line) | more_lines], remaining}

      [incomplete] ->
        {[], incomplete}
    end
  end

  # Fire-and-forget command cast — display priority (appended to back of queue).
  @impl GenServer
  def handle_cast({:command, command}, state) do
    case write_display_command(state, command) do
      {:ok, new_state} ->
        Logger.debug("USB command sent: #{command}")
        {:noreply, new_state}

      {:error, reason} ->
        Logger.error("Failed to send USB command: #{inspect(reason)}")
        {:noreply, state}
    end
  end

  # Sysinfo query — prepended to front of queue for priority dispatch.
  @impl GenServer
  def handle_cast({:query_command, command, tag}, state) do
    new_state = %{state | command_queue: [{:query, command, tag} | state.command_queue]}

    case maybe_dispatch_next(new_state) do
      {:ok, dispatched} -> {:noreply, dispatched}
      _ -> {:noreply, new_state}
    end
  end

  # Multi-command sequence — prepended atomically to front of queue.
  @impl GenServer
  def handle_cast({:command_sequence, commands}, state) do
    new_state = %{state | command_queue: commands ++ state.command_queue}

    case maybe_dispatch_next(new_state) do
      {:ok, dispatched} -> {:noreply, dispatched}
      _ -> {:noreply, new_state}
    end
  end

  # If the driver is ready and the queue is non-empty, immediately dispatch the next command.
  defp maybe_dispatch_next(%{ready: true, command_queue: [next | rest]} = state) do
    case send_command(state, next) do
      {:ok, new_state} -> {:ok, %{new_state | command_queue: rest}}
      error -> error
    end
  end

  defp maybe_dispatch_next(state), do: {:ok, state}

  # Initializes USB connection and configures display.
  # State flow:
  # 1. Terminates any previous UART process and starts a fresh one
  # 2. Opens the serial port
  # 3. Queues initialization commands (display priority + sysinfo queries)
  # 4. Sends newline to trigger the initial prompt
  defp initialize_connection(state) do
    safe_close(state.uart)

    with {:ok, uart} <- start_uart(),
         :ok <- uart_open(uart, state.device) do
      Logger.debug("USB serial port opened: #{state.device}")

      initial_state = %{
        state
        | uart: uart,
          connected: true,
          counter: 0,
          ready: false,
          buffer: "",
          log_buffer: "",
          prompt_retries: 0
      }

      init_commands = [
        {:display, "wifi stop"},
        {:display, "config_rendering_mode differential"},
        {:display, "flipdot_clear"},
        {:query, "show_version", :version},
        {:query, "config_show", :config}
      ]

      queued_state =
        Enum.reduce(init_commands, initial_state, fn cmd, acc_state ->
          Logger.debug("Queueing init command: #{inspect(cmd)}")
          %{acc_state | command_queue: acc_state.command_queue ++ [cmd]}
        end)

      case uart_write(uart, "\n") do
        :ok ->
          {:ok, queued_state}

        error ->
          safe_close(uart)
          error
      end
    else
      {:error, :port_timed_out} ->
        Logger.debug("USB port timed out while opening #{state.device}, will retry")
        {:error, :port_timed_out}

      {:error, reason} = error ->
        Logger.debug("Unable to initialize USB connection: #{inspect(reason)}")
        error
    end
  end

  # Circuits.UART.open/3 and write/2 are GenServer.calls into the native port.
  # When the port does not respond (device off, firmware hung), circuits_uart
  # kills the UART GenServer with :port_timed_out instead of returning
  # {:error, _}. Catch the exit so our driver survives and retries.
  defp safe_uart_call(fun) do
    try do
      fun.()
    catch
      :exit, {:noproc, _} -> {:error, :noproc}
      :exit, reason -> {:error, reason}
    end
  end

  defp uart_open(uart, device) do
    safe_uart_call(fn ->
      Circuits.UART.open(uart, device, speed: @device_bitrate, active: true)
    end)
  end

  defp uart_write(nil, _data), do: {:error, :noproc}

  defp uart_write(uart, data) when is_pid(uart) do
    if Process.alive?(uart) do
      safe_uart_call(fn -> Circuits.UART.write(uart, data) end)
    else
      {:error, :noproc}
    end
  end

  defp start_uart do
    case Circuits.UART.start_link() do
      {:ok, uart} = ok ->
        Process.unlink(uart)
        ok

      error ->
        error
    end
  end

  # Resets all connection-related state after the USB link is lost or could
  # not be established. The caller is responsible for closing the UART process
  # (safe_close/1) and scheduling the next :try_connect.
  defp disconnected_state(state) do
    %{
      state
      | connected: false,
        ready: false,
        uart: nil,
        buffer: "",
        log_buffer: "",
        command_queue: [],
        last_sent: nil,
        prompt_retries: 0
    }
  end

  # Terminates the UART process without calling Circuits.UART.close/1.
  #
  # Circuits.UART.close/1 is a blocking GenServer.call to the native port. When
  # the device is switched off or firmware is hung, the native port does not
  # respond and the call times out, crashing the UART GenServer with
  # :port_timed_out (logged as an OTP error). Instead we unlink and send
  # :shutdown, which terminates the process immediately and is not logged at
  # error level by OTP.
  defp safe_close(nil), do: :ok

  defp safe_close(uart) when is_pid(uart) do
    if Process.alive?(uart) do
      Process.unlink(uart)
      Process.exit(uart, :shutdown)
    end

    :ok
  end

  # Send a tagged command tuple over UART and update last_sent tracking.
  defp send_command(state, {:display, cmd}) do
    do_send(state, cmd, {:display})
  end

  defp send_command(state, {:query, cmd, tag}) do
    do_send(state, cmd, {:query, tag})
  end

  defp do_send(state, cmd, last_sent_tag) do
    case uart_write(state.uart, cmd <> "\n") do
      :ok ->
        Logger.debug("Command sent: #{inspect(cmd)}")
        timer_ref = Process.send_after(self(), :prompt_timeout, @prompt_timeout)
        {:ok, %{state | ready: false, prompt_timer: timer_ref, last_sent: last_sent_tag}}

      error ->
        error
    end
  end

  # Appends a display command to the back of the queue, or sends immediately if ready.
  defp write_display_command(state, cmd) do
    cond do
      not state.connected ->
        {:error, :not_connected}

      state.ready ->
        send_command(state, {:display, cmd})

      true ->
        Logger.debug("Queueing display command (#{length(state.command_queue)} in queue)")
        {:ok, %{state | command_queue: state.command_queue ++ [{:display, cmd}]}}
    end
  end

  # Extracts the response text from the accumulated buffer after a query completes.
  # The buffer contains: "echoed_command\r\nresponse_lines\r\nprompt"
  defp extract_query_response(buffer) do
    without_prompt = Regex.replace(@prompt_regex, buffer, "")

    without_prompt
    |> String.split("\n", parts: 2)
    |> List.last("")
    |> String.replace("\r\n", "\n")
    |> String.replace("\r", "\n")
    |> String.trim()
  end

  @impl GenServer
  def terminate(_reason, state) do
    safe_close(state.uart)
  end
end
