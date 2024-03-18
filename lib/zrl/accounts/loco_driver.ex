defmodule Zrl.Accounts.LocoDriver do
  use Ecto.Schema
  import Ecto.Changeset
  alias Zrl.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_loco_driver" do
    field :status, :string, default: "D"
    # field :user_id, :string
    # field :maker_id, :id
    # field :checker_id, :id

    belongs_to :maker, Zrl.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Zrl.Accounts.User, foreign_key: :checker_id, type: :id
    belongs_to :user, Zrl.Accounts.User, foreign_key: :user_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(loco_driver, attrs) do
    loco_driver
    |> cast(attrs, [:status, :user_id, :maker_id, :checker_id])
    # |> validate_required([:status, :user_id, :maker_id])
    |> validate_inclusion(:status, ~w(A D))
    |> unique_constraint(:user_id, name: :unique_loco_driver, message: "Already exists")
  end
end
