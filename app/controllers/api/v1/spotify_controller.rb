module Api
  module V1
    class SpotifyController < ApplicationController
      def auth
        query_params = {
          client_id: ENV['SPOTIFY_CLIENT_ID'],
          response_type: 'code',
          redirect_uri: callback_url,
          scope: 'user-read-email playlist-read-private',
          show_dialog: true
        }

        redirect_to "https://accounts.spotify.com/authorize?#{query_params.to_query}", allow_other_host: true
      end

      def callback
        code = params[:code]
        token_response = exchange_token(code)

        if token_response[:access_token]
          user_data = fetch_user_profile(token_response[:access_token])

          OAuthConnection.create!(
            provider: 'spotify',
            uid: user_data['id'],
            access_token: token_response[:access_token],
            refresh_token: token_response[:refresh_token],
            expires_at: Time.now + token_response[:expires_in].to_i.seconds,
            token_type: token_response[:token_type],
            scope: token_response[:scope],
            extra_data: {
              display_name: user_data['display_name'],
              email: user_data['email'],
              country: user_data['country']
            }
          )

          render json: {
            message: "Spotify connected!",
            user: user_data,
            access_token: token_response[:access_token]
          }
        else
          render json: { error: 'Failed to get access token', response: token_response }, status: :unauthorized
        end
      end

      def me
        connection = OAuthConnection.spotify
        if connection
          profile = SpotifyService.new(connection).fetch_user_profile
          render json: profile
        else
          render json: { error: 'No Spotify connection found' }, status: :not_found
        end
      end

      def playlists
        connection = OAuthConnection.spotify
        unless connection
          return render json: { error: "No Spotify connection found" }, status: :not_found
        end
      
        connection.refresh_token_if_expired!
        token = connection.access_token
      
        playlists = []
        url = "https://api.spotify.com/v1/me/playlists?limit=50"
      
        while url
          uri = URI(url)
          req = Net::HTTP::Get.new(uri)
          req["Authorization"] = "Bearer #{token}"
      
          res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
      
          if res.code.to_i == 200
            body = JSON.parse(res.body)
            playlists.concat(body["items"])
            url = body["next"]
          else
            return render json: { error: "Failed to fetch playlists", response: res.body }, status: :bad_gateway
          end
        end
      
        render json: { total: playlists.size, playlists: playlists }
      end

      private

      def exchange_token(code)
        uri = URI('https://accounts.spotify.com/api/token')
        res = Net::HTTP.post_form(uri, {
          grant_type: 'authorization_code',
          code: code,
          redirect_uri: callback_url,
          client_id: ENV['SPOTIFY_CLIENT_ID'],
          client_secret: ENV['SPOTIFY_CLIENT_SECRET']
        })
        JSON.parse(res.body).with_indifferent_access
      end

      def fetch_user_profile(access_token)
        uri = URI('https://api.spotify.com/v1/me')
        req = Net::HTTP::Get.new(uri)
        req['Authorization'] = "Bearer #{access_token}"

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(req)
        end

        JSON.parse(res.body)
      end

      def callback_url
        "#{ENV['BASE_URL']}/api/v1/auth/spotify/callback"
      end
    end
  end
end