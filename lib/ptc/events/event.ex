defmodule Ptc.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :name, :string
    field :url, :string
    field :tags, {:array, :string}, default: []
    field :start_date, :date
    field :end_date, :date
    field :is_paid, :boolean, default: false
    field :location, :string
    field :observation, :string

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :url, :tags, :start_date, :end_date, :is_paid, :location, :observation])
    |> validate_required([:name])
    |> validate_date_order()
  end

  defp validate_date_order(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    if start_date && end_date && Date.compare(start_date, end_date) == :gt do
      add_error(changeset, :end_date, "must be after start date")
    else
      changeset
    end
  end
end
