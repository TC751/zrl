defmodule Zrl.SystemUtilities.Refueling do
  use Ecto.Schema
  import Ecto.Changeset

  alias Zrl.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_refueling_type" do
    field :category, :string
    field :code, :string
    field :description, :string
    field :status, :string, default: "D"
    # field :maker_id, :id
    # field :checker_id, :id

    belongs_to :maker, Zrl.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Zrl.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(refueling, attrs) do
    refueling
    |> cast(attrs, [:code, :description, :category, :status, :maker_id, :checker_id])
    |> validate_required([:description, :category])
    |> unique_constraint(:code, name: :unique_refueling_code, message: "already exists")
  end
end
