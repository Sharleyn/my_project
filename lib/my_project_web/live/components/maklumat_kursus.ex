defmodule MyProjectWeb.MaklumatKursus do
  use Phoenix.Component

  def maklumat_kursus(assigns) do
    ~H"""
    <section>
      <h2 class="text-xl font-semibold mb-4">Senarai Kursus</h2>
      <table class="min-w-full bg-white border text-sm">
        <thead class="bg-gray-100">
          <tr>
            <th class="border px-4 py-2 text-left">Nama</th>
            <th class="border px-4 py-2 text-left">Kategori</th>
            <th class="border px-4 py-2 text-left">Lokasi</th>
            <th class="border px-4 py-2 text-left">Tindakan</th> <!-- Tambahan -->
          </tr>
        </thead>
        <tbody>
          <%= for kursus <- @kursus_list do %>
            <tr class="hover:bg-gray-50">
              <td class="border px-4 py-2"><%= kursus.nama %></td>
              <td class="border px-4 py-2"><%= kursus.kategori %></td>
              <td class="border px-4 py-2"><%= kursus.lokasi %></td>
              <td class="border px-4 py-2 space-x-2">
                <button
                  phx-click="edit_kursus"
                  phx-value-id={kursus.id}
                  class="text-blue-600 hover:underline text-sm"
                >
                  Edit
                </button>

                <button
                  phx-click="delete_kursus"
                  phx-value-id={kursus.id}
                  data-confirm="Anda pasti mahu padam kursus ini?"
                  class="text-red-600 hover:underline text-sm"
                >
                  Padam
                </button>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </section>
    """
  end
end
