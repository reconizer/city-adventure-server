defmodule Domain.Profile.Profile do

  @moduledoc """
  Domain for profile management
  """
  @type t :: %__MODULE__{}

  defstruct [:id, :nick, :email]

  
end