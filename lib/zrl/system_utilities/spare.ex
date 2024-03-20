defmodule Zrl.SystemUtilities.Spare do
  use Ecto.Schema
  import Ecto.Changeset
  alias Zrl.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_spares" do
    field :code, :string
    field :description, :string
    field :status, :string, default: "D"

    belongs_to :maker, Zrl.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Zrl.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(spare, attrs) do
    spare
    |> cast(attrs, [:code, :description, :maker_id, :checker_id, :status])
    |> validate_required([:description])
    |> unique_constraint(:description)
    |> unique_constraint(:code, name: :unique_code, message: "already exists")
  end
end
