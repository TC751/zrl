defmodule Zrl.SystemUtilities.DefectSpare do
  use Ecto.Schema
  import Ecto.Changeset
  alias Zrl.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_defect_spares" do
    # field :spare_id, :id
    # field :defect_id, :id
    belongs_to :spare, Zrl.SystemUtilities.Spare, foreign_key: :spare_id, type: :id
    belongs_to :defect, Zrl.SystemUtilities.Defect, foreign_key: :defect_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(defect_spare, attrs) do
    defect_spare
    |> cast(attrs, [:spare_id, :defect_id])
    |> validate_required([])
  end
end
