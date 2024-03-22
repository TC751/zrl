defmodule Zrl.Locomotives.Locomotive do
  use Ecto.Schema
  import Ecto.Changeset
  alias Zrl.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_locomotive" do
    field :description, :string
    field :loco_number, :string
    # field :model, :string
    # field :type_id, :string
    # field :weight, :float
    field :status, :string, default: "D"
    field :loco_engine_capacity, :decimal, precision: 18, scale: 2

    belongs_to :owner, Zrl.Accounts.RailwayAdministrator, foreign_key: :owner_id, type: :id
    belongs_to :model, Zrl.SystemUtilities.Model, foreign_key: :model_id, type: :id
    belongs_to :type, Zrl.Locomotives.LocomotiveType, foreign_key: :type_id, type: :id
    belongs_to :maker, Zrl.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Zrl.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(locomotive, attrs) do
    locomotive
    |> cast(attrs, [
      :description,
      :loco_number,
      :model_id,
      :status,
      :type_id,
      :maker_id,
      :checker_id,
      :owner_id,
      :loco_engine_capacity
    ])
    |> validate_required([:loco_number, :status, :type_id])
  end
end
