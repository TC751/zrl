defmodule Zrl.Notifications.Email do
  use Ecto.Schema
  import Ecto.Changeset
  alias Zrl.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_email_alerts" do
    field :email, :string
    field :status, :string
    field :type, :string

    belongs_to :maker, Zrl.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Zrl.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [:type, :email, :status, :maker_id, :checker_id])
    |> validate_required([:type, :email, :status])
  end
end
