defmodule MyProjectWeb.AdminDashboardLive do
  use MyProjectWeb, :live_view

  alias MyProject.Accounts.User
  alias MyProject.Repo

  import Ecto.Query
  import MyProjectWeb.MaklumatKursus


  def mount(_params, _session, socket) do
    menus = [
      %{id: "dashboard", label: "Dashboard", path: ~p"/admin?menu=dashboard"},
      %{
        id: "kursus",
        label: "Pendaftaran Kursus",
        path: ~p"/admin?menu=kursus",
        children: [
          %{id: "kursus_ict", label: "ICT dan Teknologi", path: ~p"/admin?menu=kursus_ict"},
          %{id: "kursus_kulinari", label: "Kulinari dan Hospitaliti", path: ~p"/admin?menu=kulinari"},
          %{id: "kursus_pertanian", label: "Pertanian dan Agro", path: ~p"/admin?menu=kursus_pertanian"},
          %{id: "kursus_kemahiran", label: "Kemahiran Teknikal dan Vokasional", path: ~p"/admin?menu=kursus_kemahiran"},
          %{id: "kursus_kecantikan", label: "Kecantikan dan Gaya Hidup", path: ~p"/admin?menu=kecantikan"},
          %{id: "kursus_keusahawanan", label: "Keusahawanan dan Perniagaan", path: ~p"/admin?menu=keusahawanan"},
          %{id: "kursus_kesihatan", label: "Kesihatan dan Keselamatan", path: ~p"/admin?menu=kursus_kesihatan"},
          %{id: "kursus_seni", label: "Seni dan Kreativiti", path: ~p"/admin?menu=kursus_seni"}
        ]
      },
      %{
        id: "peserta",
        label: "Senarai Peserta",
        path: ~p"/admin?menu=peserta",
        children: [
          %{id: "diterima", label: "Diterima", path: ~p"/admin?menu=diterima"},
          %{id: "ditolak", label: "Ditolak", path: ~p"/admin?menu=ditolak"},
          %{id: "pending", label: "Pending", path: ~p"/admin?menu=pending"},
          %{id: "tamat", label: "Tamat", path: ~p"/admin?menu=tamat"}
        ]
      },
      %{id: "tetapan", label: "Tetapan", path: ~p"/admin?menu=tetapan"}
    ]

    # ✅ Hanya satu return di sini

    kursus_list = [
      %{id: 1, nama: "Kursus Elixir", kategori: "Coding", lokasi: "Online"},
      %{id: 2, nama: "Phoenix Framework", kategori: "Web", lokasi: "KL"}
    ]

    socket =
      socket
      |> assign(:kursus_list, kursus_list)

    {:ok,
     socket
     |> assign(:menus, menus)
     |> assign(:selected_menu, "dashboard")
     |> assign(:sidebar_open, true)
     |> assign(:kursus_list, kursus_list)     # ← jika belum lagi
     |> assign(:kursus_edit, nil)   # untuk edit kursus
     |> assign(:filter, "") # second step tambah filter
     |> assign(:page, 1)
     |> assign(:per_page, 5)
     |> assign(:peserta_diterima, [])
     |> assign(:total_diterima, 0)
     |> assign(:query, "")
} #step 4 filtering sbb ada semua peserta =

  end


  # Untuk menu diterima DENGAN page
  def handle_params(%{"menu" => "diterima", "page" => page} = params, _uri, socket) do
    page = String.to_integer(page || "1")
    per_page = socket.assigns.per_page || 5
    filter = socket.assigns.filter || ""
    query_text = Map.get(params, "query", "") # ← ambil teks carian jika ada

    # ✅ Gunakan base_query untuk filter + carian
    base_query =
      from(u in User,
        where:
          (u.status == ^filter or ^filter == "") and
          (ilike(u.name, ^"%#{query_text}%") or ilike(u.email, ^"%#{query_text}%"))
      )

    peserta =
      base_query
      |> limit(^per_page)
      |> offset(^((page - 1) * per_page))
      |> Repo.all()

    total =
      base_query
      |> Repo.aggregate(:count, :id)

    semua_status =
      from(u in User,
        select: u.status,
        distinct: true
      )
      |> Repo.all()

    {:noreply,
     socket
     |> assign(:selected_menu, "diterima")
     |> assign(:peserta_diterima, peserta)
     |> assign(:page, page)
     |> assign(:per_page, per_page)
     |> assign(:query, query_text)
     |> assign(:filter, filter)
     |> assign(:total_diterima, total)
     |> assign(:semua_status, semua_status)}
  end


  # Untuk menu diterima TANPA page
  def handle_params(%{"menu" => "diterima"}, _uri, socket) do
    {:noreply, push_patch(socket, to: ~p"/admin?menu=diterima&page=1")}
    end

  def handle_params(%{"menu" => menu}, _uri, socket) do
    {:noreply, assign(socket, :selected_menu, menu)}
  end

  def handle_params(%{}, _uri, socket) do
    {:noreply, assign(socket, :selected_menu, "dashboard")}
  end


    def handle_event("toggle_sidebar", _, socket) do
      {:noreply, assign(socket, :sidebar_open, !socket.assigns.sidebar_open)}
    end

    #Third step filtering dropdown (handle event)
   def handle_event("filter_peserta", %{"filter" => filter}, socket) do
  per_page = socket.assigns.per_page || 5

  query =
    from(u in User,
      where: u.status == ^filter or ^filter == "",
      limit: ^per_page,
      offset: 0
    )

  peserta = Repo.all(query)

  total =
    from(u in User, where: u.status == ^filter or ^filter == "")
    |> Repo.aggregate(:count, :id)

  {:noreply,
   socket
   |> assign(:filter, filter)
   |> assign(:page, 1)
   |> assign(:peserta_diterima, peserta)
   |> assign(:total_diterima, total)}
end

def handle_event("search", %{"query" => query}, socket) do
  filter = socket.assigns.filter || ""
  per_page = socket.assigns.per_page || 5

  query_peserta =
    from(u in User,
      where:
        (u.status == ^filter or ^filter == "") and
        (ilike(u.name, ^"%#{query}%") or ilike(u.email, ^"%#{query}%")),
      limit: ^per_page,
      offset: 0
    )

  peserta = Repo.all(query_peserta)

  total =
    from(u in User,
      where:
        (u.status == ^filter or ^filter == "") and
        (ilike(u.name, ^"%#{query}%") or ilike(u.email, ^"%#{query}%"))
    )
    |> Repo.aggregate(:count, :id)

  {:noreply,
   socket
   |> assign(:query, query)
   |> assign(:page, 1)
   |> assign(:peserta_diterima, peserta)
   |> assign(:total_diterima, total)}
end



    def handle_event("delete_kursus", %{"id" => id}, socket) do
      id = String.to_integer(id)
      baru = Enum.reject(socket.assigns.kursus_list, &(&1.id == id))

      {:noreply, assign(socket, :kursus_list, baru)}
    end

    def handle_event("edit_kursus", %{"id" => id}, socket) do
      id = String.to_integer(id)
      kursus = Enum.find(socket.assigns.kursus_list, &(&1.id == id))

      {:noreply, assign(socket, :kursus_edit, kursus)}

      # Di sini, anda boleh buka borang kemaskini (bukan scope permintaan ini lagi)
      IO.inspect(kursus)

      {:noreply, socket}
    end

    def handle_event("simpan_kursus", %{"kursus" => params}, socket) do
      id = String.to_integer(params["id"])
      baru = %{
        id: id,
        nama: params["nama"],
        kategori: params["kategori"],
        lokasi: params["lokasi"]
      }

      dikemaskini =
        Enum.map(socket.assigns.kursus_list, fn kursus ->
          if kursus.id == id, do: baru, else: kursus
        end)

      {:noreply,
       socket
       |> assign(:kursus_list, dikemaskini)
       |> assign(:kursus_edit, nil)}
    end


    # ✅ Tambah di sini: Delete peserta
    def handle_event("delete_peserta", %{"id" => id}, socket) do
      id = String.to_integer(id)
      user = Repo.get(User, id)

      if user do
        {:ok, _} = Repo.delete(user)
      end

      # Refresh peserta selepas delete
      page = socket.assigns.page
      per_page = socket.assigns.per_page
      filter = socket.assigns.filter || ""

      query =
        from(u in User,
          where: u.status == ^filter or ^filter == "",
          limit: ^per_page,
          offset: ^((page - 1) * per_page)
        )

      peserta = Repo.all(query)

      total =
        from(u in User, where: u.status == ^filter or ^filter == "")
        |> Repo.aggregate(:count, :id)

      {:noreply,
       socket
       |> assign(:peserta_diterima, peserta)
       |> assign(:total_diterima, total)}
    end

    def render(assigns) do
      ~H"""
      <div>

        <!-- Burger button sentiasa muncul di atas -->
        <div class="fixed top-4 left-4 z-60">
        <button phx-click="toggle_sidebar" class="text-white bg-[#0a2540] p-2 rounded-md shadow-lg">
          ☰
        </button>
        </div>

        <!-- ✅ Sidebar: Akan muncul jika @sidebar_open == true -->
        <%= if @sidebar_open do %>
        <aside class="fixed top-0 left-0 h-screen w-64 bg-[#0a2540] text-white z-50 shadow-lg transition-transform duration-300 lg:translate-x-0">
         <!-- 🔁 Tajuk -->
        <div class="p-6 text-xl font-semibold tracking-wide border-b border-white/10">
        Admin Panel
        </div>

        <!-- 🔁 Butang tutup -->
        <div class="p-4">
        <button phx-click="toggle_sidebar" class="text-white bg-[#0a2540] p-2 rounded-md">
        ☰
        </button>
        </div>


        <!-- 🔁Menu -->
        <nav class="p-4 space-y-1">
        <ul>
        <%= for menu <- @menus do %>
        <li>
        <.link patch={menu.path}
        class={"block px-4 py-2 rounded-md transition-all duration-200 text-sm #{if @selected_menu == menu.id, do: "bg-white text-[#0a2540] font-semibold", else: "hover:bg-[#132d4f]"}"}>
        <%= menu.label %>
        </.link>

        <!-- ✅ Submenu -->
        <%= if Map.has_key?(menu, :children) and (@selected_menu == menu.id or @selected_menu in Enum.map(menu.children, & &1.id)) do %>
        <ul class="ml-4 mt-1 space-y-1">
        <%= for child <- menu.children do %>
        <li>
        <.link patch={child.path}
        class={"block px-3 py-1 rounded-md text-sm text-white transition hover:bg-[#1a3b5f] #{if @selected_menu == child.id, do: "bg-[#132d4f] text-[#0a2540] font-semibold", else: ""}"}>
        <%= child.label %>
        </.link>
        </li>
        <% end %>
        </ul>
        <% end %>
        </li>
        <% end %>
        </ul>
        </nav>
        </aside>
        <% end %>

        <!-- ✅Main content -->
        <main class="flex-1 bg-white text-black p-6 overflow-auto">
          <%= case @selected_menu do %>
            <% "dashboard" -> %>
              <section><h2 class="text-2xl font-bold mb-4">Dashboard</h2><p>Selamat datang ke papan pemuka admin.</p></section>

            <% "kursus" -> %>
              <section><h2 class="text-2xl font-bold mb-4">Pendaftaran Kursus</h2><p>Daftar kursus baharu di sini.</p></section>


              <!-- ✅import dari live>components>maklumat_user (untuk edit kursus) -->
              <%= if @selected_menu == "kursus" do %>
              <.maklumat_kursus kursus_list={@kursus_list} kursus_edit={@kursus_edit} />
              <% end %>

              <!-- ✅Sub Menu untuk Jenis Kursus -->
                <% "kursus_ict" -> %>
                <section>
                <h2 class="text-2xl font-bold mb-4">Kursus ICT dan Teknologi</h2>
                <p>Maklumat kursus di bawah ICT.</p>
                </section>

                <% "kursus_kulinari" -> %>
                <section>
                <h2 class="text-2xl font-bold mb-4">Kursus Kulinari dan Hospitaliti</h2>
                <p>Maklumat kursus di bawah Kulinari dan Hospitaliti.</p>
                </section>

                <% "kursus_pertanian" -> %>
                <section>
                <h2 class="text-2xl font-bold mb-4">Kursus Pertanian dan Agro</h2>
                <p>Maklumat kursus di bawah Pertanian dan Agro.</p>
                </section>

                <% "kursus_kemahiran" -> %>
                <section>
                <h2 class="text-2xl font-bold mb-4">Kursus Kemahiran Teknikal dan Vokasional</h2>
                <p>Maklumat kursus di bawah Kemahiran Teknikal dan Vokasional.</p>
                </section>

                <% "kursus_kecantikan" -> %>
                <section>
                <h2 class="text-2xl font-bold mb-4">Kursus Kecantikan dan Gaya Hidup</h2>
                <p>Maklumat kursus di bawah Kecantikan dan Gaya Hidup.</p>
                </section>

                <% "kursus_keusahawanan" -> %>
                <section>
                <h2 class="text-2xl font-bold mb-4">Kursus Keusahawanan dan Perniagaan</h2>
                <p>Maklumat kursus di bawah Keusahawanan dan Perniagaan.</p>
                </section>

                <% "kursus_kesihatan" -> %>
                <section>
                <h2 class="text-2xl font-bold mb-4">Kursus Kesihatan dan Keselamatan</h2>
                <p>Maklumat kursus di bawah Kesihatan dan Keselamatan.</p>
                </section>

                <% "kursus_seni" -> %>
                <section>
                <h2 class="text-2xl font-bold mb-4">Kursus Seni dan Kreativiti</h2>
                <p>Maklumat kursus di bawah Seni dan Kreativiti.</p>
                </section>


            <% "peserta" -> %>
              <section><h2 class="text-2xl font-bold mb-4">Senarai Peserta</h2><p>Senarai peserta yang mendaftar.</p></section>

              <% "diterima" -> %>
                <section>
                <h2 class="text-2xl font-bold mb-4">Senarai Peserta > Diterima</h2>

              <!-- 🔎 Search + Dropdown sebaris -->
              <div class="mb-4 flex items-center space-x-4">

                 <!-- 🔍 Search Bar dengan ikon -->
                <form phx-change="search" phx-submit="search" class="relative flex-1">
                  <input
                    type="text"
                    name="query"
                    value={@query || ""}
                    placeholder="Cari nama atau email..."
                    class="pl-8 border border-gray-300 rounded px-2 py-1 text-sm"
                  />
                  <span class="absolute left-2 top-1/2 transform -translate-y-1/2 text-gray-400 text-sm">
                    🔍
                  </span>
                </form>


                  <!-- Dropdown -->
                  <form phx-change="filter_peserta">
                    <select name="filter" class="border border-gray-300 rounded px-2 py-1 text-sm">
                      <option value="">  Semua   </option>
                      <%= for status <- Enum.sort(@semua_status) do %>
                        <option value={status} selected={@filter == status}><%= status %></option>
                      <% end %>
                    </select>
                  </form>

                </div>


                 <!-- ✅ Jadual peserta -->
                <%= if @peserta_diterima != [] do %>
                <table class="w-full max-w-7xl bg-white border border-gray-200 shadow-sm">
                <thead>
                <tr class="bg-gray-100 text-left text-sm font-semibold text-gray-700">
                <th class="px-4 py-2 border-b">#</th>
                <th class="px-4 py-2 border-b">Name</th>
                <th class="px-4 py-2 border-b">Emel</th>
                <th class="px-4 py-2 border-b">Status</th>
                <th class="px-4 py-2 border-b">Tindakan</th>
                </tr>
                </thead>
                <tbody>
                <%= for {peserta, index} <- Enum.with_index(@peserta_diterima, 0) do %>
                <tr class="hover:bg-gray-50 text-sm">
                <td class="px-4 py-2 border-b"><%= ((@page - 1) * @per_page) + index + 1 %></td>
                <td class="px-4 py-2 border-b"><%= peserta.name %></td>
                <td class="px-4 py-2 border-b"><%= peserta.email %></td>
                <td class="px-4 py-2 border-b"><%= peserta.status %></td>
                <td class="px-4 py-2 border-b space-x-2">
                <button phx-click="edit_peserta" phx-value-id={peserta.id} class="px-2 py-1 text-sm text-white bg-blue-500 rounded hover:bg-blue-600">Edit</button>
                <button phx-click="delete_peserta" phx-value-id={peserta.id} class="px-2 py-1 text-sm text-white bg-red-500 rounded hover:bg-red-600" data-confirm="Adakah anda pasti ingin padam peserta ini?">Padam</button>
                 </td>
                  </tr>
                  <% end %>
                  </tbody>
                  </table>
                  <% else %>
                  <p class="text-gray-500">Tiada peserta diterima buat masa ini.</p>
                  <% end %>


                <!-- ✅ Pagination -->
                <div class="flex justify-center mt-6 space-x-2">
                <%= if @page > 1 do %>
                <.link patch={"?menu=diterima&page=#{@page - 1}"} class="px-4 py-2 border rounded hover:bg-gray-100">← Sebelum</.link>
                <% end %>

                <span class="px-4 py-2 border rounded bg-gray-100">Page <%= @page %></span>

                <%= if @page * @per_page < @total_diterima do %>
                <.link patch={"?menu=diterima&page=#{@page + 1}"} class="px-4 py-2 border rounded hover:bg-gray-100">Seterusnya →</.link>
                <% end %>
                </div>
                 </section>


                <% "ditolak" -> %>
                <section>
                <h2 class="text-2xl font-bold mb-4">Ditolak</h2>
                <p>Maklumat peserta yang ditolak.</p>
                </section>

                <% "pending" -> %>
                <section>
                <h2 class="text-2xl font-bold mb-4">Pending</h2>
                <p>Maklumat peserta yang masih pending.</p>
                </section>

                <% "tamat" -> %>
                <section>
                <h2 class="text-2xl font-bold mb-4">Tamat</h2>
                <p>Maklumat peserta yang telah tamat kursus.</p>
                </section>

            <% "tetapan" -> %>
              <section><h2 class="text-2xl font-bold mb-4">Tetapan</h2><p>Konfigurasi sistem dan akaun.</p></section>

            <% _ -> %>
              <section><h2 class="text-2xl font-bold mb-4">Selamat Datang</h2><p>Sila pilih menu dari sebelah kiri.</p></section>
          <% end %>
        </main>
      </div>
      """
    end
  end
