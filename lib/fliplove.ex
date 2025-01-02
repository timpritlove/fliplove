defmodule Fliplove do
  @moduledoc """
  Flipdot keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def priv_dir do
    Path.join([:code.priv_dir(:fliplove)])
  end

  def static_dir do
    Path.join([priv_dir(), "static"])
  end
end
