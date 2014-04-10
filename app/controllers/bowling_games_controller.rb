class BowlingGamesController < ApplicationController
  def edit
    binding.pry
    @bowling_game = BowlingGame.find(params[:id])
  end

  def update
    bowling_game = BowlingGame.find(params[:id])
    Throw.create(pins:params[:pins],bowling_game:bowling_game)
    redirect_to edit_bowling_game_path(bowling_game)
  end
end
