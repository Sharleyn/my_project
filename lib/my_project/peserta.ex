defmodule MyProject.Peserta do
  import Ecto.Query, warn: false
  alias MyProject.Repo
  alias MyProject.Peserta.PesertaSchema

  def list_diterima_peserta(page, per_page) do
    PesertaSchema
    |> where([p], p.status == "diterima")
    |> order_by(desc: :inserted_at)
    |> offset(^((page - 1) * per_page))
    |> limit(^per_page)
    |> Repo.all()
  end

  def count_diterima_peserta do
    PesertaSchema
    |> where([p], p.status == "diterima")
    |> select([p], count(p.id))
    |> Repo.one()
  end
end
