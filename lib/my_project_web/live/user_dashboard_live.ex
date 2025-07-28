
  defmodule MyProjectWeb.UserDashboardLive do
    use MyProjectWeb, :live_view

    def mount(_params, _session, socket) do
      {:ok, socket}
    end

    def handle_params(%{"menu" => menu}, _uri, socket) do
      {:noreply, assign(socket, selected_menu: menu)}
    end

    def handle_params(_params, _uri, socket) do
      {:noreply, assign(socket, selected_menu: nil)}
    end

    def render(assigns) do
      ~H"""
      <aside class="fixed top-0 left-0 h-screen w-64 bg-gray-800 text-white z-50">
        <div class="p-4 text-lg font-semibold border-b border-gray-700">
          User Panel
        </div>
        <nav class="h-full overflow-y-auto p-4">
          <ul class="space-y-2">
            <li>
              <.link patch={~p"/user?menu=menu1"} class={"block p-2 rounded #{if @selected_menu == "menu1", do: "bg-gray-900 font-bold", else: "hover:bg-gray-700"}"}>
                Menu 1
              </.link>
            </li>
            <li>
              <.link patch={~p"/user?menu=menu2"} class={"block p-2 rounded #{if @selected_menu == "menu2", do: "bg-gray-900 font-bold", else: "hover:bg-gray-700"}"}>
                Menu 2
              </.link>
            </li>
            <li>
              <.link patch={~p"/user?menu=menu3"} class={"block p-2 rounded #{if @selected_menu == "menu3", do: "bg-gray-900 font-bold", else: "hover:bg-gray-700"}"}>
                Menu 3
              </.link>
            </li>
             <li>
              <.link patch={~p"/user?menu=home"} class={"block p-2 rounded #{if @selected_menu == "home", do: "bg-gray-900 font-bold", else: "hover:bg-gray-700"}"}>
                Home
              </.link>
            </li>
          </ul>
        </nav>
      </aside>

      <main class="ml-64 h-screen overflow-y-auto bg-white p-6">
        <%= if @selected_menu == "menu1" do %>
          <div>
            <h2 class="text-xl font-bold">Ini kandungan Menu 1</h2>
            <p>Contoh isi menu 1 di sini.</p>
          </div>
        <% else %>
          <%= if @selected_menu == "menu2" do %>
            <div>
              <h2 class="text-xl font-bold">Ini kandungan Menu 2</h2>
              <p>Contoh isi menu 2 di sini.</p>
            </div>
        <% else %>
            <%= if @selected_menu == "menu3" do %>
              <div>
                <h2 class="text-xl font-bold">Ini kandungan Menu 3</h2>
                <p>Contoh isi menu 3 di sini.</p>
              </div>
        <% else %>
              <%= if @selected_menu == "home" do %>
              <div>
                <h2 class="text-2xl font-bold mb-4">Welcome to User Dashboard</h2>
                <p>Sila pilih menu di sebelah kiri untuk mula.</p>
              </div>
        <% else %>
              <div>
                <h2 class="text-2xl font-bold mb-4">Welcome to User Dashboard</h2>
                <p>Sila pilih menu di sebelah kiri untuk mula.</p>
              </div>
              <% end %>
            <% end %>
          <% end %>
        <% end %>
      </main>
      """
    end
  end
