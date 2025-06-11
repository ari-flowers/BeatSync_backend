Rails.application.routes.draw do
  # Skip default Devise controllers, since we’re using custom JWT-based auth
  devise_for :users, skip: [:sessions, :registrations, :passwords]

  namespace :api do
    namespace :v1 do
      # Custom auth endpoints for JWT
      devise_scope :user do
        post '/sign_in', to: 'sessions#create'
        delete '/sign_out', to: 'sessions#destroy'
        post '/sign_up', to: 'registrations#create'
      end

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