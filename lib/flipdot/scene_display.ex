defmodule Flipdot.SceneDisplay do
  use Scenic.Scene
  import Scenic.Primitives
  import Scenic.Components
  alias Scenic.Graph

  def init(scene, _param, _opts) do
    graph =
      Graph.build()
      |> rect({8, 8}, stroke: {1, :yellow}, t: {100, 100})

    scene = push_graph(scene, graph)

    {:ok, scene}
  end
end
