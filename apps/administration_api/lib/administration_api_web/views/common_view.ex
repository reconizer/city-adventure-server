defmodule AdministrationApiWeb.CommonView do
  use AdministrationApiWeb, :view

  def render("empty.json", _) do
    %{}
  end
end
