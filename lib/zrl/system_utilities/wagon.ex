defmodule Zrl.SystemUtilities.Wagon do
  use Ecto.Schema
  use Endon
  import Ecto.Changeset
  alias Zrl.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_wagon" do
    field :code, :string
    field :description, :string
    field :status, :string
    field :load_status, :string, default: "E"
    field :wagon_symbol, :string
    field :mvt_status, :string, default: "N"
    field :assigned, :string, default: "NO"
    # field :owner_id
    # field :wagon_type, :string
    # field :maker_id, :id
    # field :checker_id, :id
    belongs_to :maker, Zrl.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Zrl.Accounts.User, foreign_key: :checker_id, type: :id
    belongs_to :wagon_type, Zrl.SystemUtilities.WagonType, foreign_key: :wagon_type_id, type: :id
    belongs_to :wagon_sub_type, Zrl.SystemUtilities.WagonType, foreign_key: :wagon_sub_type_id, type: :id
    belongs_to :wagon_owner, Zrl.Accounts.RailwayAdministrator, foreign_key: :owner_id, type: :id
    belongs_to :station, Zrl.SystemUtilities.Station, foreign_key: :station_id, type: :id
    belongs_to :condition, Zrl.SystemUtilities.Condition, foreign_key: :condition_id, type: :id
    belongs_to :domain, Zrl.SystemUtilities.Domain, foreign_key: :domain_id, type: :id
    belongs_to :customer, Zrl.Accounts.Clients, foreign_key: :allocated_cust_id, type: :id

    belongs_to :wagon_status, Zrl.SystemUtilities.WagonType,
      foreign_key: :wagon_status_id,
      type: :id

    belongs_to :commodity, Zrl.SystemUtilities.Commodity, foreign_key: :commodity_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(wagon, attrs) do
    wagon
    |> cast(attrs, [
      :code,
      :description,
      :status,
      :wagon_type_id,
      :owner_id,
      :maker_id,
      :checker_id,
      :wagon_symbol,
      :station_id,
      :condition_id,
      :load_status,
      :mvt_status,
      :assigned,
      :allocated_cust_id,
      :domain_id,
      :wagon_status_id,
      :commodity_id,
      :wagon_sub_type_id
    ])
    |> validate_required([:code, :wagon_type_id, :owner_id])
    |> validate_inclusion(:status, ~w(A D))
    |> validate_inclusion(:mvt_status, ~w(A N))
    |> validate_length(:code, min: 1, max: 10, message: " should be 1 - 10 character(s)")
    |> validate_length(:description, min: 1, max: 50, message: " should be 1 - 50 character(s)")
    |> unique_constraint(:code, name: :unique_code, message: "already exists")
  end
end
