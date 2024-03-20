defmodule Zrl.SystemUtilities.Rates do
  use Ecto.Schema
  import Ecto.Changeset
  alias Zrl.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_fuel_rates" do
    field :code, :string
    field :fuel_rate, :decimal, precision: 18, scale: 2
    field :month, :string
    field :start_date, :date
    field :refueling_depo, :string
    field :status, :string, default: "D"
    # field :maker_id, :id
    # field :checker_id, :id

    belongs_to :maker, Zrl.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Zrl.Accounts.User, foreign_key: :checker_id, type: :id
    belongs_to :depo, Zrl.SystemUtilities.Distance, foreign_key: :refueling_depo_id, type: :id
    belongs_to :refuel_depo, Zrl.SystemUtilities.Station, foreign_key: :station_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(rates, attrs) do
    rates
    |> cast(attrs, [
      :code,
      :fuel_rate,
      :month,
      :start_date,
      :refueling_depo,
      :status,
      :maker_id,
      :checker_id,
      :station_id
    ])
    |> validate_required([:fuel_rate, :month, :status])
    |> validate_inclusion(:status, ~w(A D))
    |> validate_length(:code, min: 1, max: 20, message: " should be 1 - 20 character(s)")
    |> unique_constraint(:code, name: :unique_fuel_code, message: "already exists")
    |> unique_constraint(:station_id,
      name: :unique_date,
      message: "Error. the refueling depo with the same date already exists"
    )
  end
end
