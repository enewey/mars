defmodule IceBreakerTest do
  use ExUnit.Case, async: true

  alias IceBreaker.Board

  describe "new/0" do
    test "generates a new ice breaker game" do
      game = IceBreaker.new()

      assert %IceBreaker{current_player: 0, players: 2} = game
    end
  end

  describe "new/2" do
    test "generates a new ice breaker game with a penguin at the given coords" do
      game = IceBreaker.new(2,2)

      assert %IceBreaker{current_player: 0, players: 2} = game

      penguin = Board.cell_at(game.board, 2, 2)
      assert penguin.rowspan > 0
      assert penguin.colspan > 0
    end
  end

  describe "play/3" do
    test "plays a move on the current game" do
      game = IceBreaker.new(2,2) |> IceBreaker.play(0, 0)

      assert %IceBreaker{current_player: 1, players: 2} = game
      assert not Board.has_cell?(game.board, 0, 0)
    end

    test "ignores multiple plays on the same space" do
      game =
        IceBreaker.new(2,2)
        |> IceBreaker.play(0, 0)
        |> IceBreaker.play(0, 0)

      # current_player should still be 1
      assert %IceBreaker{current_player: 1, players: 2} = game
      assert not Board.has_cell?(game.board, 0, 0)
    end

    test "disallows plays on a penguin-occupied space" do
      game =
        IceBreaker.new(2,2)
        |> IceBreaker.play(3, 2)
        |> IceBreaker.play(3, 3)
        |> IceBreaker.play(2, 3)
        |> IceBreaker.play(2, 2)

      assert %IceBreaker{current_player: 0, players: 2} = game
      assert Board.has_cell?(game.board, 2, 2)
      assert length(game.board.cells) == 33
    end
  end
end
