defmodule Session do
  @moduledoc """
  Documentation for Session.
  """
  defstruct \
  errors: [],
  valid?: true,
  context: %{}

  def add_error(%Session{errors: errors} = session, error) do
    %{session | errors: [error | errors]}
    |> invalidate
  end

  @doc """
    Invalidates session status - cannot be reversed
  """
  def invalidate(%Session{} = session) do
    %{session | valid?: false}
  end

  @doc """
    Sets context for session
  """
  def set_context(%Session{} = session, context) do
    %{session | context: context}
  end

  @doc """
    Updates context for session
  """
  def update_context(%Session{context: context} = session, new_context) when is_map(context) do
    %{session | context: Map.merge(context, new_context)}
  end

  def update_context(%Session{context: _} = session, new_context) do
    %{session | context: new_context}
  end

  @doc """
    Creates new session object
  """
  def construct(_), do: construct()
  def construct(), do: %Session{}

end
