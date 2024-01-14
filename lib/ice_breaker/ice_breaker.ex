defmodule IceBreaker do
  @moduledoc """
  Ice Breaker game core.

  IceBreaker is a game on a 6x6 grid of blocks, upon which sits a penguin.
  The penguin occupies a 2x2 space on the grid, and their space is counted
  as a single block.
  All other blocks surrounding are single 1x1 blocks.

  The idea of the game is players take turns removing blocks from the
  game. Every block that is removed reduces the stability of surrounding blocks.

  A block is "stable" if all other cells either in the same row or same column
  are occupied by a block.

  🞕🞕🞕🞕🞕🞕
  🞕🞕🞕🞕🞕🞕
  🞕🞕▛▜🞕🞕
  🞕🞕▙▟🞕🞕
  🞕🞕🞕🞕🞕🞕
  🞕🞕🞕🞕🞕🞕

  When a block is unstable, it falls, and is removed from the board.

  When a player takes a move that makes the penguin block unstable,
  they lose the game.
  """

  alias IceBreaker.Board

  defstruct board: nil, players: 2, current_player: 0

  @type t :: %__MODULE__{
    board: Board.t(),
    players: integer(),
    current_player: integer()
  }

  @doc "Creates a new game with a randomly placed penguin."
  @spec new() :: t()
  def new() do
    p_row = Enum.random(0..4)
    p_col = Enum.random(0..4)

    %__MODULE__{
      board: Board.init(p_row, p_col),
      players: 2,
      current_player: 0
    }
  end

  @doc """
  Performs a move in the game.
  """
  @spec play(t(), integer(), integer()) :: t()
  def play(%__MODULE__{} = game, row, col) do
    with {:ok, game_moved} <- move_if_valid(game, row, col),
      {:ok, game_next_turn} <- check_next_turn(game_moved) do
        IO.puts("Player #{game.current_player} moved.")
        IO.puts(Board.draw(game_next_turn.board))
        IO.puts("Player #{game_next_turn.current_player}'s turn!")
        game_next_turn
      else
        {:error, :bad_move, game_bad} ->
          IO.puts("Invalid move! Game state unchanged.")
          game_bad
        {:error, :game_over, game_over} ->
          IO.puts("OH NO! Penguin knocked down!")
          IO.puts(Board.draw(game_over.board))
          IO.puts("Player #{game_over.current_player} loses! Good game!")
          game_over
      end
  end

  defp move_if_valid(game, row, col) do
    if valid_move?(game, row, col) do
      updated_board = game.board |> Board.poke(row, col) |> coalesce_unstable()
      {:ok, %__MODULE__{game | board: updated_board}}
    else
      {:error, :bad_move, game}
    end
  end

  # checks if the game is over and sets the current player to the next player
  # if the game ended (i.e. penguin was knocked unstable) returns an error tuple
  defp check_next_turn(game) do
    game.board.cells
    |> Enum.any?(fn cell -> cell.rowspan > 0 || cell.colspan > 0 end)
    |> case do
      true -> {:ok, %__MODULE__{game | current_player: rem(game.current_player + 1, game.players)}}
      false -> {:error, :game_over, game}
    end
  end

  @spec valid_move?(t(), integer(), integer()) :: boolean()
  defp valid_move?(%__MODULE__{board: board}, row, col) do
    cell = Board.cell_at(board, row, col)
    (not is_nil(cell)) and cell.rowspan == 0 and cell.colspan == 0
  end

  defp coalesce_unstable(%Board{} = board) do
    new_cells = Enum.filter(board.cells, &Board.is_cell_stable?(board, &1.row, &1.col))
    new_board = %Board{board | cells: new_cells}

    if length(new_board.cells) != length(board.cells),
      do: coalesce_unstable(new_board),
      else: new_board
  end

end
