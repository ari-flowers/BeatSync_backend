Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      devise_for :users,
                 controllers: {
                   sessions: 'api/v1/sessions',
                   registrations: 'api/v1/registrations'
                 },
                 path: '',
                 path_names: {
                   sign_in: 'users/sign_in',
                   sign_out: 'users/sign_out',
                   registration: 'users'
                 },
                 defaults: { format: :json } # <- Add this!

      # UserConnections: manage OAuth credentials per provider
      resources :user_connections, only: [:index, :show, :create, :update, :destroy]

      # Playlists and nested tracks
      resources :playlists, only: [:index, :show, :create, :update, :destroy] do
        resources :tracks, only: [:index, :create]
      end

      # Top-level access to tracks
      resources :tracks, only: [:show, :update, :destroy]

      # Spotify OAuth routes
      get '/auth/spotify', to: 'spotify#auth'
      get '/auth/spotify/callback', to: 'spotify#callback'
    end
  end
end