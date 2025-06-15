defmodule Fliplove do
  @moduledoc """
  Flipdot keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def priv_dir do
    Application.app_dir(:fliplove, "priv")
  end

  def static_dir do
    Application.app_dir(:fliplove, "priv/static")
  end
end
