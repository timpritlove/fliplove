defmodule FliploveWeb.SysinfoLive do
  use FliploveWeb, :live_view
  alias Fliplove.Sysinfo
  alias Fliplove.Driver.FluepdotUsb
  import FliploveWeb.CoreComponents

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    usb_mode? = System.get_env("FLIPLOVE_DRIVER") == "FLUEPDOT_USB"

    socket =
      socket
      |> assign(:page_title, "System Info")
      |> assign(:version, nil)
      |> assign(:config, nil)
      |> assign(:wifi_form, to_form(%{}, as: :wifi))
      |> assign(:hostname_form, to_form(%{}, as: :hostname))
      |> assign(:last_action, nil)

    cond do
      usb_mode? and connected?(socket) ->
        Phoenix.PubSub.subscribe(Fliplove.PubSub, Sysinfo.topic())
        Sysinfo.query_version()
        Sysinfo.query_config()
        {:ok, assign(socket, :device_state, :waiting)}

      usb_mode? ->
        {:ok, assign(socket, :device_state, :waiting)}

      true ->
        {:ok, assign(socket, :device_state, :not_configured)}
    end
  end

  # ---------------------------------------------------------------------------
  # Driver state messages
  # ---------------------------------------------------------------------------

  @impl Phoenix.LiveView
  def handle_info({:usb_driver_state, :ready}, socket) do
    # After a reboot the device config may have changed (e.g. saved hostname
    # or WiFi settings now active) — refresh the info cards automatically.
    if socket.assigns.last_action == :reboot do
      Sysinfo.query_config()
    end

    {:noreply,
     socket
     |> assign(:device_state, :ready)
     |> assign(:last_action, nil)}
  end

  @impl Phoenix.LiveView
  def handle_info({:usb_driver_state, :disconnected}, socket) do
    {:noreply,
     socket
     |> assign(:device_state, :disconnected)
     |> assign(:last_action, nil)}
  end

  # ---------------------------------------------------------------------------
  # Query responses
  # ---------------------------------------------------------------------------

  @impl Phoenix.LiveView
  def handle_info({:usb_response, :version, text}, socket) do
    version = Sysinfo.parse_version(text)
    {:noreply, assign(socket, :version, version)}
  end

  @impl Phoenix.LiveView
  def handle_info({:usb_response, :config, text}, socket) do
    config = Sysinfo.parse_config(text)

    wifi_form =
      to_form(
        %{
          "ssid" => config["ssid"],
          "password" => config["password"],
          "ap_mode" => config["wifi_mode"] == "ap"
        },
        as: :wifi
      )

    hostname_form =
      to_form(%{"hostname" => config["hostname"]}, as: :hostname)

    {:noreply,
     socket
     |> assign(:config, config)
     |> assign(:wifi_form, wifi_form)
     |> assign(:hostname_form, hostname_form)}
  end

  # ---------------------------------------------------------------------------
  # Events
  # ---------------------------------------------------------------------------

  @impl Phoenix.LiveView
  def handle_event("save-wifi", %{"wifi" => params}, socket) do
    ssid = params["ssid"] || ""
    password = params["password"] || ""
    ap_mode = params["ap_mode"] == "true"

    if ap_mode do
      Sysinfo.save_wifi_ap(ssid, password)
    else
      Sysinfo.save_wifi_station(ssid, password)
    end

    {:noreply, assign(socket, :last_action, :save)}
  end

  @impl Phoenix.LiveView
  def handle_event("save-hostname", %{"hostname" => params}, socket) do
    hostname = params["hostname"] || ""
    Sysinfo.save_hostname(hostname)
    {:noreply, assign(socket, :last_action, :save)}
  end

  @impl Phoenix.LiveView
  def handle_event("reboot", _params, socket) do
    Sysinfo.reboot()

    {:noreply,
     socket
     |> assign(:device_state, :waiting)
     |> assign(:last_action, :reboot)}
  end

  @impl Phoenix.LiveView
  def handle_event("usb-command", %{"command" => command}, socket) do
    GenServer.cast(FluepdotUsb, {:command, command})
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("refresh", _params, socket) do
    Sysinfo.query_version()
    Sysinfo.query_config()
    {:noreply, assign(socket, :device_state, :waiting)}
  end

  # ---------------------------------------------------------------------------
  # Render
  # ---------------------------------------------------------------------------

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="min-h-screen bg-gray-900 text-gray-100">
        <div class="max-w-4xl mx-auto px-4 py-8">
          <%!-- Header --%>
          <div class="flex items-center gap-4 mb-8">
            <.link navigate={~p"/"} class="text-gray-400 hover:text-gray-200 transition-colors">
              <.icon name="hero-arrow-left" class="h-6 w-6" />
            </.link>
            <h1 class="text-3xl font-bold">System Info</h1>
            <div class="ml-auto">
              <button
                :if={@device_state == :ready}
                phx-click="refresh"
                class="px-4 py-2 bg-gray-700 hover:bg-gray-600 rounded-lg flex items-center gap-2 text-sm transition-colors"
              >
                <.icon name="hero-arrow-path" class="h-4 w-4" /> Refresh
              </button>
            </div>
          </div>

          <%!-- Not configured --%>
          <div :if={@device_state == :not_configured} class="bg-gray-800 p-6 rounded-lg text-center">
            <.icon name="hero-exclamation-triangle" class="h-12 w-12 mx-auto mb-4 text-yellow-500" />
            <p class="text-lg font-semibold mb-2">USB not configured</p>
            <p class="text-gray-400">
              Set <code class="bg-gray-700 px-1 rounded">FLIPLOVE_DRIVER=FLUEPDOT_USB</code>
              to enable USB device management.
            </p>
          </div>

          <%!-- Disconnected --%>
          <div :if={@device_state == :disconnected} class="bg-gray-800 p-6 rounded-lg text-center">
            <.icon name="hero-exclamation-triangle" class="h-12 w-12 mx-auto mb-4 text-red-500" />
            <p class="text-lg font-semibold mb-2">Device disconnected</p>
            <p class="text-gray-400">The USB device is not connected or unavailable. Reconnecting automatically…</p>
          </div>

          <%!-- Status banner while waiting --%>
          <div
            :if={@device_state == :waiting}
            class={[
              "mb-6 p-4 rounded-lg flex items-center gap-3",
              if(@last_action == :reboot, do: "bg-amber-900/40 border border-amber-700", else: "bg-gray-800")
            ]}
          >
            <svg
              class="animate-spin h-5 w-5 text-indigo-400 flex-shrink-0"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
            >
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path
                class="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
              >
              </path>
            </svg>
            <span class="text-sm">
              <%= cond do %>
                <% @last_action == :reboot -> %>
                  Rebooting device — waiting for it to come back online…
                <% @last_action == :save -> %>
                  Saving configuration…
                <% true -> %>
                  Connecting to device…
              <% end %>
            </span>
          </div>

          <%!-- Main content — shown when we have data or are in ready/waiting state with data --%>
          <div :if={@device_state in [:ready, :waiting]} class="space-y-6">
            <%!-- System Card --%>
            <.info_card title="System">
              <div :if={is_nil(@version)} class="text-gray-500 italic">Loading…</div>
              <dl :if={@version} class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <.info_row label="IDF Version" value={@version["idf_version"]} />
                <.info_row label="Chip Model" value={@version["model"]} />
                <.info_row label="Cores" value={@version["cores"]} />
                <.info_row label="Revision" value={@version["revision"]} />
                <.info_row label="Features" value={@version["features"]} class="sm:col-span-2" />
              </dl>
            </.info_card>

            <%!-- Configuration Card — hostname (editable) + rendering mode --%>
            <.info_card title="Configuration">
              <div :if={is_nil(@config)} class="text-gray-500 italic">Loading…</div>
              <div :if={@config} class="space-y-4">
                <form id="hostname-form" phx-submit="save-hostname" class="space-y-3">
                  <div>
                    <label class="block text-sm text-gray-400 mb-1">Hostname</label>
                    <div class="flex gap-2">
                      <input
                        type="text"
                        name="hostname[hostname]"
                        value={@hostname_form[:hostname].value}
                        class="flex-1 px-3 py-2 bg-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 text-sm"
                        autocomplete="off"
                      />
                      <button
                        type="submit"
                        class="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 rounded-lg text-sm transition-colors"
                      >
                        Save
                      </button>
                    </div>
                    <p class="text-xs text-gray-500 mt-1">Takes effect after reboot.</p>
                  </div>
                </form>
                <.info_row label="Rendering Mode" value={@config["rendering_mode"]} />
              </div>
            </.info_card>

            <%!-- WiFi Card --%>
            <.info_card title="WiFi">
              <div :if={is_nil(@config)} class="text-gray-500 italic">Loading…</div>
              <div :if={@config} class="space-y-4">
                <div class="flex items-center gap-2">
                  <span class="text-sm text-gray-400">Current mode:</span>
                  <span class={[
                    "px-2 py-0.5 rounded text-xs font-semibold",
                    if(@config["wifi_mode"] == "ap", do: "bg-amber-700 text-amber-100", else: "bg-green-700 text-green-100")
                  ]}>
                    {if @config["wifi_mode"] == "ap", do: "Access Point", else: "Station"}
                  </span>
                </div>

                <form id="wifi-form" phx-submit="save-wifi" class="space-y-3">
                  <div>
                    <label class="block text-sm text-gray-400 mb-1">SSID</label>
                    <input
                      type="text"
                      name="wifi[ssid]"
                      value={@wifi_form[:ssid].value}
                      class="w-full px-3 py-2 bg-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 text-sm"
                      autocomplete="off"
                    />
                  </div>
                  <div>
                    <label class="block text-sm text-gray-400 mb-1">Password</label>
                    <input
                      type="text"
                      name="wifi[password]"
                      value={@wifi_form[:password].value}
                      class="w-full px-3 py-2 bg-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 text-sm"
                      autocomplete="off"
                    />
                  </div>
                  <div class="flex items-center gap-2">
                    <input
                      type="checkbox"
                      id="ap-mode"
                      name="wifi[ap_mode]"
                      value="true"
                      checked={@wifi_form[:ap_mode].value == true}
                      class="w-4 h-4 text-indigo-600 bg-gray-700 border-gray-600 rounded focus:ring-indigo-500"
                    />
                    <label for="ap-mode" class="text-sm text-gray-300">Access Point mode</label>
                  </div>
                  <div>
                    <button
                      type="submit"
                      class="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 rounded-lg text-sm transition-colors"
                    >
                      Save WiFi Settings
                    </button>
                    <p class="text-xs text-gray-500 mt-2">Takes effect after reboot.</p>
                  </div>
                </form>
              </div>
            </.info_card>

            <%!-- RS485 Card --%>
            <.info_card title="RS485">
              <div :if={is_nil(@config)} class="text-gray-500 italic">Loading…</div>
              <dl :if={@config} class="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <.info_row label="Mode" value={@config["rs485_mode"]} />
                <.info_row label="Address" value={@config["rs485_address"]} />
                <.info_row label="Baudrate" value={@config["rs485_baudrate"]} />
              </dl>
            </.info_card>

            <%!-- Flipdot Panels Card --%>
            <.info_card title="Flipdot Panels">
              <div :if={is_nil(@config)} class="text-gray-500 italic">Loading…</div>
              <div :if={@config} class="space-y-3">
                <.info_row label="Panel Count" value={@config["panel_count"]} />
                <div :if={@config["panel_sizes"] != []} class="flex flex-wrap gap-2">
                  <span
                    :for={{size, idx} <- Enum.with_index(@config["panel_sizes"])}
                    class="px-3 py-1 bg-gray-700 rounded text-sm"
                  >
                    Panel {idx}: {size}px
                  </span>
                </div>
              </div>
            </.info_card>

            <%!-- USB Commands Card --%>
            <.info_card title="USB Commands">
              <div class="flex flex-wrap gap-2">
                <.usb_cmd tooltip="Clear Display" command="flipdot_clear" icon="hero-backspace" />
                <.usb_cmd
                  tooltip="Clear Display (Inverted)"
                  command="flipdot_clear --invert"
                  icon="hero-adjustments-horizontal"
                />
                <.usb_cmd tooltip="Start WiFi" command="wifi start" icon="hero-signal" />
                <.usb_cmd tooltip="Stop WiFi" command="wifi stop" icon="hero-no-symbol" />
                <.usb_cmd tooltip="Show Tasks" command="show_tasks" icon="hero-list-bullet" />
                <button
                  phx-click="reboot"
                  title="Reboot Device"
                  data-confirm="Reboot the device? This will take several seconds."
                  class="flex items-center gap-2 px-3 py-2 bg-red-800 hover:bg-red-700 rounded-lg text-sm transition-colors"
                >
                  <.icon name="hero-power" class="h-5 w-5" />
                  <span>Reboot</span>
                </button>
              </div>
            </.info_card>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  # ---------------------------------------------------------------------------
  # Private components
  # ---------------------------------------------------------------------------

  defp info_card(assigns) do
    ~H"""
    <div class="bg-gray-800 p-5 rounded-lg">
      <h2 class="text-lg font-semibold mb-4 text-gray-100">{@title}</h2>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :label, :string, required: true
  attr :value, :string, default: ""
  attr :class, :string, default: nil

  defp info_row(assigns) do
    ~H"""
    <div class={@class}>
      <dt class="text-xs text-gray-400 uppercase tracking-wide mb-0.5">{@label}</dt>
      <dd class="text-sm font-mono text-gray-100">{@value || "—"}</dd>
    </div>
    """
  end

  attr :tooltip, :string, required: true
  attr :command, :string, required: true
  attr :icon, :string, required: true

  defp usb_cmd(assigns) do
    ~H"""
    <button
      title={@tooltip}
      phx-click="usb-command"
      phx-value-command={@command}
      class="p-3 bg-gray-700 hover:bg-indigo-700 rounded-lg transition-colors"
    >
      <.icon name={@icon} class="h-5 w-5" />
    </button>
    """
  end
end
