Rails.application.routes.draw do
  devise_for :users

  namespace :api do
    namespace :v1 do
      # UserConnections: manage OAuth credentials per provider
      resources :user_connections, only: [:index, :show, :create, :update, :destroy]

      # Playlists and nested tracks
      resources :playlists, only: [:index, :show, :create, :update, :destroy] do
        resources :tracks, only: [:index, :create] # Nested: tracks within a playlist
      end

      # Top-level access to tracks (e.g. search, global list)
      resources :tracks, only: [:show, :update, :destroy]

      # Spotify OAuth routes
      get '/auth/spotify', to: 'spotify#auth'
      get '/auth/spotify/callback', to: 'spotify#callback'
    end
  end
end