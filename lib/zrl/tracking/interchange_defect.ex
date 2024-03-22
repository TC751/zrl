defmodule Zrl.Tracking.InterchangeDefect do
  use Ecto.Schema
  use Endon
  import Ecto.Changeset
  alias Zrl.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_interchange_defects" do

    field :status, :string, default: "A"
    belongs_to :interchange, Zrl.Tracking.Interchange, foreign_key: :interchange_id, type: :id
    belongs_to :wagon, Zrl.SystemUtilities.Wagon, foreign_key: :wagon_id, type: :id
    belongs_to :spare, Zrl.SystemUtilities.SpareFee, foreign_key: :spare_id, type: :id
    belongs_to :defect_spare, Zrl.SystemUtilities.Spare, foreign_key: :defect_spare_id, type: :id
    belongs_to :defect, Zrl.SystemUtilities.Defect, foreign_key: :defect_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(interchange_defect, attrs) do
    interchange_defect
    |> cast(attrs, [:interchange_id, :spare_id, :wagon_id, :defect_id, :status, :defect_spare_id])
    |> validate_required([:interchange_id, :defect_id])
  end
end
