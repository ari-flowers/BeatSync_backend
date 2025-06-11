Rails.application.routes.draw do
  devise_for :users
  # API routes
  namespace :api do
    namespace :v1 do
      resources :user_connections, only: [:index, :show, :create, :update, :destroy]
      resources :playlists, only: [:index, :show, :create, :update, :destroy] do
        resources :tracks, only: [:index, :show, :create, :update, :destroy]
      end
    end
  end

  # Spotify OAuth routes
  get '/auth/spotify', to: 'spotify#auth'
  get '/auth/spotify/callback', to: 'spotify#callback'
end