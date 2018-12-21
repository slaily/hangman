defmodule GameTest do
  use ExUnit.Case

  alias Hangman.Game

  test "new_game returns structure" do
    game = Game.new_game()

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
  end

  test "state isn't changed for :won or :lost game" do
    for state <- [ :won, :lost] do
      game = Game.new_game() |> Map.put(:game_state, state)

      assert { ^game, _ } = Game.make_move(game, "x")
    end
  end

  test "first occurrence of letter is not already used" do
    game = Game.new_game()
    { game, _tally } = Game.make_move(game, "x")

    assert game.game_state != :already_used
  end

  test "second occurrence of letter is already used" do
    game = Game.new_game()
    { game, _tally } = Game.make_move(game, "x")
    assert game.game_state != :already_used
    { game, _tally } = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "a good guess is recognized" do
    game = Game.new_game("wibble")
    { game, _tally } = Game.make_move(game, "w")

    assert game.game_state == :good_guess
    assert game.turns_left == 7
  end

  test "a guessed word is a won game" do
    moves = [
      {"w", :good_guess},
      {"i", :good_guess},
      {"b", :good_guess},
      {"b", :already_used},
      {"l", :good_guess},
      {"e", :won},
    ]

    assert_final_game_state(moves, "wibble", :won, 7)
  end

  test "bad guess is recognized" do
    game = Game.new_game("wibble")
    { game, _tally } = Game.make_move(game, "x")

    assert game.game_state == :bad_guess
    assert game.turns_left == 6
  end

  test "lost game is recognized" do
    moves = [
      {"w", :bad_guess},
      {"i", :bad_guess},
      {"b", :bad_guess},
      {"b", :already_used},
      {"l", :bad_guess},
      {"d", :bad_guess},
      {"e", :lost},
    ]

    assert_final_game_state(moves, "hangman", :bad_guess, 1)
  end

  def assert_final_game_state(moves, guess_word, final_game_state, final_turns_left) do
    game = Game.new_game(guess_word)
    fun = fn ({ guess, _state }, game) ->
            { game, _tally} = Game.make_move(game, guess)
            game
          end
    final_game = Enum.reduce(moves, game, fun)

    assert final_game.game_state == final_game_state
    assert final_game.turns_left == final_turns_left
  end
end
