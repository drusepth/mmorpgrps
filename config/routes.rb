Rails.application.routes.draw do
  get 'world/:id/map', to: 'world#map'
  get 'world/:id/map/players', to: 'world#player_map'
  get 'world/:id/scoreboards', to: 'world#scoreboards'

  root 'world#map'
end
