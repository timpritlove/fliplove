defmodule Flipdot do
  @moduledoc """
  Flipdot keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def priv_dir do
    :code.priv_dir(:flipdot) |> List.to_string()
  end

  def static_dir do
    priv_dir() <> "/static/"
  end
end
