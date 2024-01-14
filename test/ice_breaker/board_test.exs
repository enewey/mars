defmodule IceBreaker.BoardTest do
  use ExUnit.Case, async: true
  doctest IceBreaker.Board

  alias IceBreaker.Board
  alias IceBreaker.Cell

  setup do
    %{board: Board.init(2,2), pr: 2, pc: 2}
  end

  describe "init/2" do
    test "Generates valid board" do
      board = Board.init(2,3)

      for r <- 0..5 do
        for c <- 0..5 do
          found = Enum.filter(board.cells, fn cell -> Cell.test(cell, r,c) end)
          assert length(found) == 1
        end
      end

      # 32 1x1 cells + 1 2x2 cell
      ones = Enum.filter(board.cells, fn cell -> cell.rowspan == 0 and cell.colspan == 0 end)
      twos = Enum.filter(board.cells, fn cell -> cell.rowspan == 1 and cell.colspan == 1 end)

      assert length(ones) == 32
      assert length(twos) == 1
    end

    test "raises error when penguin cannot be placed" do
      try do
        Board.init(5, 4)
        assert false
      rescue
        e ->
          assert "Invalid" <> _ = e.message
          true
      end
    end
  end

  describe "has_cell?/3" do
    test "will indicate a cell at a given row/col", %{board: board} do
      for r <- 0..5 do
        for c <- 0..5 do
          assert Board.has_cell?(board, r, c)
        end
      end
    end

    test "indicates missing cell", %{board: board} do
      [c | tail] = board.cells

      board = %Board{cells: tail}
      assert not Board.has_cell?(board, c.row, c.col)
    end

    test "indicates missing penguin cell", %{board: board, pr: pr, pc: pc} do
      cells = board.cells |> Enum.reject(fn cell -> cell.rowspan > 0 end)

      board = %Board{cells: cells}

      assert not Board.has_cell?(board, pr, pc)
      assert not Board.has_cell?(board, pr+1, pc)
      assert not Board.has_cell?(board, pr, pc+1)
      assert not Board.has_cell?(board, pr+1, pc+1)

    end
  end

  describe "poke/3" do
    test "removes cell that tests positive at the given row col", %{board: board} do
      new_board = Board.poke(board, 1,1)
      assert not Board.has_cell?(new_board, 1,1)
      assert length(new_board.cells) == 32
    end

    test "removal in the same coords twice does nothing", %{board: board} do
      new_board = Board.poke(board, 1,1) |> Board.poke(1,2) |> Board.poke(1,1)
      assert length(new_board.cells) == 31
    end
  end

  describe "is_cell_stable?/3" do
    test "can test stability of a 1x1 cell", %{board: board} do
      board = %{board | cells: board.cells |> Enum.reject(fn %Cell{row: row} -> row == 1 end)}
      poked = Board.poke(board, 0, 2)

      assert not Board.is_cell_stable?(poked, 0, 0)
      assert not Board.is_cell_stable?(poked, 0, 1)
      assert not Board.is_cell_stable?(poked, 0, 3)
      assert not Board.is_cell_stable?(poked, 0, 4)
      assert not Board.is_cell_stable?(poked, 0, 5)

      for r <- 2..5 do
        for c <- 0..5 do
          assert Board.is_cell_stable?(poked, r, c)
        end
      end
    end

    test "accurately tests stability of 2x2 cell", %{board: board, pr: pr, pc: pc} do
      cells = board.cells |> Enum.filter(fn
        %{row: r, col: c, rowspan: rs} -> (r != pr and c not in pc..pc+1) or rs > 0
      end)

      new_board = %{board | cells: cells}
      assert Board.is_cell_stable?(new_board, pr, pc)

      unstable_cells = cells |> Enum.reject(fn %{row: r, rowspan: rs} -> r == pr+1 and rs == 0 end)
      unstable_board = %{board | cells: unstable_cells}
      assert not Board.is_cell_stable?(unstable_board, pr, pc)
    end
  end
end
