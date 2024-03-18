defmodule Zrl.Accounts.UserRole do
  use Ecto.Schema
  import Ecto.Changeset
  alias Zrl.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_user_role" do
    # field :maker_id, :integer
    field :role_desc, :string
    field :role_str, :map
    field :status, :string

    belongs_to :maker, Zrl.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Zrl.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(user_role, attrs) do
    user_role
    |> cast(attrs, [:role_desc, :role_str, :status, :maker_id, :checker_id])
    |> validate_required([:role_desc, :role_str, :status, :maker_id])
    |> unique_constraint(:role_desc, name: :unique_role_desc, message: "already exists")
  end
end
