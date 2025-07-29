defmodule MyProject.Peserta.PesertaSchema do
  use Ecto.Schema
  import Ecto.Changeset

  schema "peserta" do
    field :nama, :string
    field :email, :string
    field :status, :string
    timestamps()
  end

  def changeset(peserta, attrs) do
    peserta
    |> cast(attrs, [:nama, :email, :status])
    |> validate_required([:nama, :email, :status])
  end
end
