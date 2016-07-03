Rails.application.routes.draw do
  get 'world/map'
  get 'world/map/players' => 'world#player_map'
  get 'world/scoreboards'

  root 'world#map'
end
