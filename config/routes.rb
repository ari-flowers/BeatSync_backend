Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get '/auth/:provider', to: 'oauth#auth'
      get '/auth/:provider/callback', to: 'oauth#callback'
      get '/auth/:provider/me', to: 'oauth#me'

      resources :oauth_connections, only: [:index, :show, :create, :update, :destroy]

      resources :playlists, only: [:index] do
        member do
          get :tracks
        end
      end

      resources :tracks, only: [:show, :update, :destroy]
    end
  end
end