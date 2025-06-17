Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # OAuth platform-agnostic connection model
      resources :oauth_connections, only: [:index, :show, :create, :update, :destroy]

      # Playlist and Track management (no user scoping)
      resources :playlists do
        resources :tracks, only: [:index, :create]
      end
      resources :tracks, only: [:show, :update, :destroy]

      # Spotify OAuth endpoints
      get '/auth/spotify', to: 'spotify#auth'
      get '/auth/spotify/callback', to: 'spotify#callback'
      get '/auth/spotify/me', to: 'spotify#me'
      get '/auth/spotify/playlists', to: 'spotify#playlists'
    end
  end
end