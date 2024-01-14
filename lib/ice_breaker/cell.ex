defmodule IceBreaker.Cell do
  @moduledoc """
  Data structure to represent a single variable-sized cell on the board
  """

  defstruct rowspan: 0, colspan: 0, row: 0, col: 0

  @type t() :: %__MODULE__{row: integer(), col: integer(), rowspan: integer(), colspan: integer()}

  @doc """
  Tests whether the cell occupies the given row/column.

  # Examples

      iex> IceBreaker.Cell.test(%IceBreaker.Cell{rowspan: 2, colspan: 2, row: 2, col: 2}, 2, 3)
      true

      iex> IceBreaker.Cell.test(%IceBreaker.Cell{rowspan: 2, colspan: 2, row: 2, col: 2}, 1, 3)
      false
  """
  @spec test(%__MODULE__{}, integer(), integer()) :: boolean()
  def test(%__MODULE__{} = cell, r, c) do
    r in row_range(cell)
      and
    c in col_range(cell)
  end

  @spec row_range(t()) :: Range.t()
  def row_range(%__MODULE__{row: row, rowspan: rowspan}), do: row..row+rowspan

  @spec col_range(t()) :: Range.t()
  def col_range(%__MODULE__{col: col, colspan: colspan}), do: col..col+colspan

end
