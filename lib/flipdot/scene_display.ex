defmodule Flipdot.SceneDisplay do
  use Scenic.Scene
  require Logger
  import Scenic.Primitives
  import Scenic.Components
  alias Flipdot.DisplayState
  alias Scenic.Graph

  def init(scene, _param, _opts) do
    graph = build_scene_graph()

    scene = push_graph(scene, graph)
    Phoenix.PubSub.subscribe(Flipdot.PubSub, Flipdot.DisplayState.topic())

    {:ok, scene}
  end

  @display_origin_x 65
  @display_origin_y 20
  @pixel_size 10
  @border_size 2

  def handle_info({:display_update, _bitmap}, scene) do
    graph = build_scene_graph()
    scene = push_graph(scene, graph)
    {:noreply, scene}
  end

  defp build_scene_graph do
    bitmap = DisplayState.get()

    graph = Graph.build()

    Enum.reduce(bitmap.matrix, graph, fn {{x, y}, value}, graph ->
      rect(graph, {@pixel_size, @pixel_size},
        stroke: {@border_size, :black},
        fill: %{1 => :yellow, 0 => :black}[value],
        t: {@display_origin_x + x * @pixel_size, @display_origin_y + (bitmap.height - 1 - y) * @pixel_size}
      )
    end)
    |> rect({(bitmap.width + 1) * @pixel_size, (bitmap.height + 1) * @pixel_size},
      stroke: {1, :yellow},
      t: {@display_origin_x - div(@pixel_size, 2), @display_origin_y - div(@pixel_size, 2)}
    )
  end
end
