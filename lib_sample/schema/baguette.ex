defmodule EctoCrux.Schema.Baguette do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %EctoCrux.Schema.Baguette{
    id: integer(),
    kind: String.t(),
    name: String.t()
  }

  schema "baguettes" do
    field(:name, :string)
    field(:kind, :string)
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
