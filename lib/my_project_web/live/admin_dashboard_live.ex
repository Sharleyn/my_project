defmodule MyProjectWeb.AdminDashboardLive do
  use MyProjectWeb, :live_view


  def mount(_params, _session, socket) do
    menus = [
      %{id: "dashboard", label: "Dashboard", path: ~p"/admin?menu=dashboard"},
      %{
        id: "kursus",
        label: "Pendaftaran Kursus",
        path: ~p"/admin?menu=kursus",
        children: [
          %{id: "kursus_kbs", label: "KBS", path: ~p"/admin?menu=kursus_kbs"},
          %{id: "kursus_jpsm", label: "JPSM", path: ~p"/admin?menu=kursus_jpsm"}
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
    peserta_diterima = [
      %{id: 1, nama: "Ali Bin Ahmad", email: "ali@example.com", status: "Admin"},
      %{id: 2, nama: "Siti Nurhaliza", email: "siti@example.com", status: "Admin"},
      %{id: 3, nama: "John Doe", email: "john@example.com", status: "User"},
      %{id: 4, nama: "Liyana Zain", email: "liyana@example.com", status: "Admin"},
      %{id: 5, nama: "Ahmad Zulkifli", email: "zul@example.com", status: "Admin"},
      %{id: 6, nama: "Zulkifli", email: "zulkifli@example.com", status: "User"},
      %{id: 7, nama: "Faizal Ramli", email: "faizal@example.com", status: "Admin"}
    ]

    {:ok,
     socket
     |> assign(:menus, menus)
     |> assign(:selected_menu, "dashboard")
     |> assign(:sidebar_open, true)
     |> assign(:peserta_diterima, peserta_diterima)
     |> assign(:page, 1)
     |> assign(:per_page, 5)
     |> assign(:total_diterima, length(peserta_diterima))
     |> assign(:peserta_diterima, Enum.slice(peserta_diterima, 0, 5))} # page 1 = peserta 1 hingga 5}

  end

  def handle_params(%{"menu" => "diterima", "page" => page}, _uri, socket) do
    page = String.to_integer(page || "1")
    per_page = socket.assigns.per_page || 5

    semua_peserta = [
      %{id: 1, nama: "Ali Bin Ahmad", email: "ali@example.com", status: "Admin"},
      %{id: 2, nama: "Siti Nurhaliza", email: "siti@example.com", status: "Admin" },
      %{id: 3, nama: "John Doe", email: "john@example.com", status: "User"},
      %{id: 4, nama: "Liyana Zain", email: "liyana@example.com", status: "Admin"},
      %{id: 5, nama: "Ahmad Zulkifli", email: "zul@example.com", status: "Admin"},
      %{id: 6, nama: "Zulkifli", email: "zulkifli@example.com", status: "User"},
      %{id: 7, nama: "Faizal Ramli", email: "faizal@example.com", status: "Admin"}
    ]

    peserta = Enum.slice(semua_peserta, (page - 1) * per_page, per_page)
    total = length(semua_peserta)

    {:noreply,
     socket
     |> assign(:selected_menu, "diterima")
     |> assign(:peserta_diterima, peserta)
     |> assign(:page, page)
     |> assign(:per_page, per_page)
     |> assign(:total_diterima, total)}
  end

  def handle_params(%{"menu" => menu}, _uri, socket) do
    {:noreply, assign(socket, :selected_menu, menu)}
  end

  def handle_params(%{}, _uri, socket) do
    {:noreply, assign(socket, :selected_menu, "dashboard")}
  end


    def handle_event("toggle_sidebar", _, socket) do
      {:noreply, update(socket, :sidebar_open, &(!&1))}
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

                <% "kursus_kbs" -> %>
                <section>
                <h2 class="text-2xl font-bold mb-4">Kursus KBS</h2>
                <p>Maklumat kursus di bawah KBS.</p>
                </section>

                <% "kursus_jpsm" -> %>
                <section>
                <h2 class="text-2xl font-bold mb-4">Kursus JPSM</h2>
                <p>Maklumat kursus di bawah JPSM.</p>
                </section>

            <% "peserta" -> %>
              <section><h2 class="text-2xl font-bold mb-4">Senarai Peserta</h2><p>Senarai peserta yang mendaftar.</p></section>

              <% "diterima" -> %>
                <section>
                <h2 class="text-2xl font-bold mb-4">Senarai Peserta > Diterima</h2>

                 <!-- ✅ Jadual peserta -->
                <%= if @peserta_diterima != [] do %>
                <table class="min-w-full bg-white border border-gray-200 shadow-sm">
                <thead>
                <tr class="bg-gray-100 text-left text-sm font-semibold text-gray-700">
                <th class="px-4 py-2 border-b">#</th>
                <th class="px-4 py-2 border-b">Nama</th>
                <th class="px-4 py-2 border-b">Emel</th>
                <th class="px-4 py-2 border-b">Status</th>
                </tr>
                </thead>
                <tbody>
                <%= for {peserta, index} <- Enum.with_index(@peserta_diterima, 0) do %>
                <tr class="hover:bg-gray-50 text-sm">
                <td class="px-4 py-2 border-b"><%= ((@page - 1) * @per_page) + index + 1 %></td>
                <td class="px-4 py-2 border-b"><%= peserta.nama %></td>
                <td class="px-4 py-2 border-b"><%= peserta.email %></td>
                <td class="px-4 py-2 border-b"><%= peserta.status %></td>
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
