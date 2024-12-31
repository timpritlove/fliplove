defmodule FlipdotWeb.VirtualDisplayComponent do
  use Phoenix.Component
  alias Flipdot.Bitmap

  def display(assigns) do
    ~H"""
    <div class="bg-gray-800 p-6 rounded-lg shadow-lg">
      <div id="display" class="bg-gray-900 p-4 rounded-lg">
        <div :for={y <- Range.new(@height - 1, 0, -1)} id={"row-#{y}"} class="flex">
          <div
            :for={x <- 0..(@width - 1)}
            id={"cell-#{x},#{y}"}
            phx-click="pixel"
            phx-value-x={x}
            phx-value-y={y}
            class={[
              "shrink-0 w-[8px] h-[8px] flex items-center justify-around",
              "transition-all duration-200 hover:opacity-75",
              if(Bitmap.get_pixel(@bitmap, {x, y}) == 1,
                do:
                  "bg-[url('/images/flipdot/flipdot-pixel-on-8x8.png')] " <>
                    "[min-resolution:2x]:bg-[url('/images/flipdot/flipdot-pixel-on-16x16.png')] " <>
                    "[min-resolution:3x]:bg-[url('/images/flipdot/flipdot-pixel-on-24x24.png')]",
                else:
                  "bg-[url('/images/flipdot/flipdot-pixel-off-8x8.png')] " <>
                    "[min-resolution:2x]:bg-[url('/images/flipdot/flipdot-pixel-off-16x16.png')] " <>
                    "[min-resolution:3x]:bg-[url('/images/flipdot/flipdot-pixel-off-24x24.png')]"
              )
            ]}
          >
          </div>
        </div>
      </div>
    </div>
    """
  end
end
