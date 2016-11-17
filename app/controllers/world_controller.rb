class WorldController < ApplicationController
  def map
    world = World.find(params[:id])

    @rocks = world.souls.where(alive: true, role: 'rock')
    @papers = world.souls.where(alive: true, role: 'paper')
    @scissors = world.souls.where(alive: true, role: 'scissor')
    @giants = world.souls.where(alive: true, role: ['rock giant', 'paper giant', 'scissors giant'])
  end

  def player_map
    @players = World.find(params[:id]).players
  end

  def scoreboards
    @world = World.find(params[:id])
  end
end
