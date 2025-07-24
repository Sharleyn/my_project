defmodule MyProjectWeb.AdminDashboardLive do

  use MyProjectWeb, :live_view

  def render(assigns) do

    ~H"""

    <div class="p-6">

      <h1 class="text-2xl font-bold mb-4">Admin Dashboard</h1>

      <p>Welcome, admin!</p>

    </div>

    """

  end

  def mount(_params, _session, socket) do

    {:ok, socket}

  end

end
