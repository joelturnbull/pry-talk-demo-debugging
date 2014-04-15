class BowlingGamesController < ApplicationController
  def edit
    @bowling_game = BowlingGame.find(params[:id])
  end

  def update
    bowling_game = BowlingGame.find(params[:id])
    pins = params[:pins]
    Throw.create(pins:pins, bowling_game:bowling_game)
    redirect_to edit_bowling_game_path(bowling_game)
  end
end
