defmodule Zrl.SystemUtilities.Condition do
  use Ecto.Schema
  import Ecto.Changeset
  alias Zrl.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_condition" do
    field :code, :string
    field :con_status, :string
    field :description, :string
    field :status, :string, default: "D"
    field :is_usable, :string

    # field :maker_id, :id
    # field :checker_id, :id

    belongs_to :maker, Zrl.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Zrl.Accounts.User, foreign_key: :checker_id, type: :id

    belongs_to :condition_cat, Zrl.SystemUtilities.ConditionCategory,
      foreign_key: :cond_category_id,
      type: :id

    timestamps()
  end

  @doc false
  def changeset(condition, attrs) do
    condition
    |> cast(attrs, [
      :code,
      :description,
      :is_usable,
      :cond_category_id,
      :status,
      :maker_id,
      :checker_id
    ])
    |> validate_required([:description])
    |> validate_inclusion(:status, ~w(A D))
    |> validate_length(:code, min: 1, max: 10, message: " should be 1 - 10 character(s)")
    |> validate_length(:description, min: 1, max: 50, message: " should be 1 - 50 character(s)")
    |> unique_constraint(:description, name: :unique_description, message: "already exists")
    |> unique_constraint(:code, name: :unique_code, message: "already exists")
  end
end
