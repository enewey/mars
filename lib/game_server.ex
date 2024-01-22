defmodule GameServer do
  @moduledoc """

  """

  use GenServer

  # Client

  def new() do
    start_link([])
  end

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil)
  end

  def play(pid, row, col) do
    GenServer.call(pid, {:play, {row, col}})
  end

  # Server

  @impl true
  def init(_) do
    new_game = IceBreaker.new()
    {:ok, new_game}
  end

  @impl true
  def handle_call({:play, {row, col}}, _from, game_state) do
    new_state = IceBreaker.play(game_state, row, col)
    {:reply, new_state.current_player, new_state}
  end

end
