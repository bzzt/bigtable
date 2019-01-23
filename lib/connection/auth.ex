defmodule Bigtable.Connection.Auth do
  @moduledoc false

  @scopes [
    "https://www.googleapis.com/auth/bigtable.data",
    "https://www.googleapis.com/auth/bigtable.data.readonly",
    "https://www.googleapis.com/auth/cloud-bigtable.data",
    "https://www.googleapis.com/auth/cloud-bigtable.data.readonly",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/cloud-platform.read-only",
    "https://www.googleapis.com/auth/bigtable.admin",
    "https://www.googleapis.com/auth/bigtable.admin.cluster",
    "https://www.googleapis.com/auth/bigtable.admin.instance",
    "https://www.googleapis.com/auth/bigtable.admin.table",
    "https://www.googleapis.com/auth/cloud-bigtable.admin",
    "https://www.googleapis.com/auth/cloud-bigtable.admin.cluster",
    "https://www.googleapis.com/auth/cloud-bigtable.admin.table"
  ]

  @doc """
  Returns the current `Goth.Token` that will be used to authorize Bigtable requests
  """
  @spec get_token() :: Goth.Token.t()
  def get_token do
    case Application.get_env(:goth, :disabled, false) do
      true ->
        %{token: ""}

      false ->
        {:ok, token} =
          @scopes
          |> Enum.join(" ")
          |> Goth.Token.for_scope()

        token
    end
  end
end
