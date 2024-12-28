defmodule Flipdot.Apps.Base do
  @moduledoc """
  Base behavior for Flipdot apps
  """

  defmacro __using__(_opts) do
    quote do
      use GenServer
      require Logger

      def start_link(opts) do
        GenServer.start_link(__MODULE__, opts, name: __MODULE__)
      end

      @impl true
      def init(opts) do
        app_name = opts[:app_name]
        Registry.register(Flipdot.Apps.Registry, :running_app, app_name)
        init_app(opts)
      end

      # To be implemented by each app
      def init_app(_opts), do: {:ok, %{}}

      defoverridable init_app: 1
    end
  end
end
