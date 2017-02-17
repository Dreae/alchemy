defmodule Alchemy.Cogs.EventHandler do
  use GenServer
  @moduledoc false
  # This server will recieve casts from the gateway, and decide which functions
  # to call to handle those casts.
  # This server is intended to be unique.


  # Starts up a task for handle registered for that event
  def notify(msg) do
    GenServer.cast(Events, {:notify, msg})
  end

  # Used at the beginning of the application to add said handles
  def add_handler(handle) do
    GenServer.cast(Events, {:add_handle, handle})
  end


  ### Server ###

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: Events)
  end


  # Adds a new handler to the map, indexed by type
  def handle_cast({:add_handle, {type, handle}}, state) do
    {:noreply,
     update_in( state, [type], fn maybe ->
       case maybe do
         nil -> [handle]
         val -> [handle | val]
       end
     end)}
  end


  def handle_cast({:notify, {type, args}}, state) do
     for {module, method} <- Map.get(state, type, []) do
       Task.start(fn -> apply(module, method, args) end)
     end
     {:noreply, state}
  end
end