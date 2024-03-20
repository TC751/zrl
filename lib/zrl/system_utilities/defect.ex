defmodule Zrl.SystemUtilities.Defect do
  use Ecto.Schema
  import Ecto.Changeset
  alias Zrl.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_defects" do
    field :code, :string
    field :description, :string
    field :status, :string, default: "D"
    field :type, :string
    field :cost, :decimal, default: 0
    field :man_hours, :decimal, default: 0

    belongs_to :maker, Zrl.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Zrl.Accounts.User, foreign_key: :checker_id, type: :id
    belongs_to :currency, Zrl.SystemUtilities.Currency, foreign_key: :currency_id, type: :id
    belongs_to :surcharge, Zrl.SystemUtilities.Surchage, foreign_key: :surcharge_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(defect, attrs) do
    defect
    |> cast(attrs, [
      :code,
      :description,
      :maker_id,
      :checker_id,
      :status,
      :currency_id,
      :surcharge_id,
      :man_hours,
      :cost,
      :type
    ])
    |> validate_required([:description])
    |> unique_constraint(:description)
    |> unique_constraint(:code, name: :unique_code, message: "already exists")
  end
end
