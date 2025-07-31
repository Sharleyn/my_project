defmodule MyProjectWeb.SearchInput do
  use Phoenix.Component

  attr :query, :string, required: true
  attr :placeholder, :string, default: "Cari..."
  attr :phx_target, :any
  attr :phx_debounce, :string, default: "300"
  attr :rest, :global

  def search(assigns) do
    ~H"""
    <input
      type="text"
      name="query"
      value={@query}
      placeholder={@placeholder}
      class="border px-3 py-1 rounded"
      phx-change="search"
      phx-debounce={@phx_debounce}
      phx-target={@phx_target}
      {@rest}
    />
    """
  end
end
