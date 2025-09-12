defmodule Fliplove.Apps.Base do
  @moduledoc """
  Base behavior for Fliplove apps
  """

  @callback cleanup_app(reason :: term(), state :: term()) :: :ok

  defmacro __using__(_opts) do
    quote do
      use GenServer
      require Logger
      @behaviour Fliplove.Apps.Base

      def start_link(opts) do
        GenServer.start_link(__MODULE__, opts, name: __MODULE__)
      end

      @impl GenServer
      def init(opts) do
        app_name = opts[:app_name]
        Registry.register(Fliplove.Apps.Registry, :running_app, app_name)
        init_app(opts)
      end

      @impl GenServer
      def terminate(reason, state) do
        Logger.debug("#{__MODULE__} terminate called with reason: #{inspect(reason)}")
        result = cleanup_app(reason, state)
        Logger.debug("#{__MODULE__} cleanup_app completed with result: #{inspect(result)}")
        result
      end

      # To be implemented by each app
      def init_app(_opts), do: {:ok, %{}}

      # Default implementation of cleanup_app
      @impl Fliplove.Apps.Base
      def cleanup_app(_reason, _state), do: :ok

      defoverridable init_app: 1, cleanup_app: 2
    end
  end
end
