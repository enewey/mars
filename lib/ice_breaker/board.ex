defmodule IceBreaker.Board do
  @moduledoc """
  Data structure to represent the board, with accessor and mutation functions
  """

  alias IceBreaker.Cell

  defstruct cells: []

  @type t :: %__MODULE__{cells: list(Cell.t())}

  @doc """
  Builds a new IceBreaker board.

  The penguin will be situated top-left justified at the provided coordinates.
  """
  @spec init(integer(), integer()) :: t()
  def init(penguin_row, penguin_col) when penguin_row > 4 or penguin_col > 4 do
    raise "Invalid penguin coords!"
  end

  def init(penguin_row, penguin_col) do
    penguin = %Cell{row: penguin_row, col: penguin_col, rowspan: 1, colspan: 1}

    cells = for r <- 0..5 do
      for c <- - 0..5 do
        case Cell.test(penguin, r, c) do
          false -> %Cell{row: r, col: c}
          true -> nil
        end
      end
    end
    |> List.flatten()
    |> Enum.reject(&is_nil/1)

    %__MODULE__{cells: [penguin | cells]}
  end

  @doc """
  Tests whether a cell exists at the specified row/col
  """
  @spec has_cell?(t(), integer(), integer()) :: boolean()
  def has_cell?(%__MODULE__{cells: cells}, r, c) do
    Enum.any?(cells, fn cell -> Cell.test(cell, r, c) end)
  end

  @doc """
  Removes the cell at the specified row/col and returns the new board.
  """
  @spec poke(t(), integer(), integer()) :: t()
  def poke(%__MODULE__{cells: cells} = board, r, c) do
    new_cells = cells |> Enum.reject(fn cell -> Cell.test(cell, r, c) end)
    %__MODULE__{board | cells: new_cells}
  end

  @doc """
  Returns true if either
  """
  @spec is_cell_stable?(t(), any(), any()) :: boolean()
  def is_cell_stable?(%__MODULE__{cells: cells} = board, r, c) do
    cell = Enum.find(cells, fn cell -> Cell.test(cell, r, c) end)
    is_cell_stable?(board, cell)
  end

  # for cell bigger than 1x1
  defp is_cell_stable?(%__MODULE__{} = board, %Cell{} = cell) do
    rows = for row <- Cell.row_range(cell) do
      for ct <- 0..5, ct not in Cell.col_range(cell) do
        has_cell?(board, row, ct)
      end
    end
    |> Enum.any?(&Enum.all?(&1))

    cols = for col <- Cell.col_range(cell) do
      for rt <- 0..5, rt not in Cell.row_range(cell) do
        has_cell?(board, rt, col)
      end
    end
    |> Enum.any?(&Enum.all?(&1))

    rows or cols
  end

  defp is_cell_stable?(_board, _cell) do
    false
  end
end
