class WorldController < ApplicationController
  def map
  	@rocks = Soul.where(alive: true, role: 'rock')
  	@papers = Soul.where(alive: true, role: 'paper')
  	@scissors = Soul.where(alive: true, role: 'scissor')
  end

  def player_map
    @players = Player.all
  end

  def scoreboards
  end
end
