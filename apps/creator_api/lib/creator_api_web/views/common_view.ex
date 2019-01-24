defmodule CreatorApiWeb.CommonView do
  use CreatorApiWeb, :view

  def render("empty.json", _) do
    %{}
  end
end
