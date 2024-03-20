defmodule Zrl.SystemUtilities.WagonType do
  use Ecto.Schema
  import Ecto.Changeset
  alias Zrl.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_wagon_type" do
    field :capacity, :string
    field :code, :string
    field :description, :string
    field :status, :string
    field :type, :string
    field :weight, :string
    field :category, :string
    # field :maker_id, :id
    # field :checker_id, :id

    belongs_to :maker, Zrl.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Zrl.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(wagon_type, attrs) do
    wagon_type
    |> cast(attrs, [
      :code,
      :description,
      :weight,
      :status,
      :maker_id,
      :checker_id,
      :category
    ])
    |> validate_required([:description, :status, :maker_id, :category])
    |> validate_inclusion(:status, ~w(A D))
    |> validate_length(:code, min: 1, max: 10, message: " should be 1 - 10 character(s)")
    |> validate_length(:description, min: 1, max: 50, message: " should be 1 - 50 character(s)")
    |> unique_constraint(:code, name: :unique_code, message: "already exists")
  end
end
