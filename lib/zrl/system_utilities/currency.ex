defmodule Zrl.SystemUtilities.Currency do
  use Ecto.Schema
  import Ecto.Changeset
  alias Zrl.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_currency" do
    field :acronym, :string
    field :code, :string
    field :description, :string
    field :symbol, :string
    field :status, :string, default: "D"
    field :type, :string
    # field :checker_id, :id

    belongs_to :maker, Zrl.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Zrl.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(currency, attrs) do
    currency
    |> cast(attrs, [
      :code,
      :acronym,
      :description,
      :symbol,
      :status,
      :type,
      :maker_id,
      :checker_id
    ])
    |> validate_required([:code, :acronym, :description, :symbol])
    |> validate_length(:code, min: 1, max: 10, message: " should be 1 - 10 character(s)")
    |> validate_length(:description, min: 1, max: 50, message: " should be 1 - 50 character(s)")
    |> unique_constraint(:code, name: :unique_code, message: "already exists")
    |> unique_constraint(:acronym, name: :unique_acronym, message: "already exists")
    |> unique_constraint(:type, name: :unique_local_currency, message: "already exists")
  end
end
