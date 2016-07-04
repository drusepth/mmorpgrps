class WorldController < ApplicationController
  def map
    @rocks = Soul.where(alive: true, role: 'rock')
    @papers = Soul.where(alive: true, role: 'paper')
    @scissors = Soul.where(alive: true, role: 'scissor')
    @giants = Soul.where(alive: true, role: ['rock giant', 'paper giant', 'scissors giant'])
  end

  def player_map
    @players = Player.all
  end

  def scoreboards
  end
end
