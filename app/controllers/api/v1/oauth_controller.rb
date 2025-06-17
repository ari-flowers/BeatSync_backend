module Api
  module V1
    class OauthController < ApplicationController
      def auth
        service = oauth_service(params[:provider])
        redirect_to service.auth_url, allow_other_host: true
      end

      def callback
        service = oauth_service(params[:provider])
        token_response = service.exchange_code_for_token(params[:code])
        user_data = service.fetch_user_profile(token_response[:access_token])

        OAuthConnection.create_or_find_by!(provider: params[:provider], uid: user_data['id']) do |conn|
          conn.access_token = token_response[:access_token]
          conn.refresh_token = token_response[:refresh_token]
          conn.expires_at = Time.current + token_response[:expires_in].to_i.seconds
          conn.extra_data = user_data
        end

        render json: {
          message: "#{params[:provider].capitalize} connected!",
          user: user_data,
          access_token: token_response[:access_token]
        }
      end

      def me
        service = oauth_service(params[:provider])
        user_data = service.fetch_user_profile(service.active_token)
        render json: user_data
      end

      private

      def oauth_service(provider)
        case provider
        when 'spotify'
          ::Oauth::SpotifyService.new # Optionally pass in current_user when auth
        else
          raise ArgumentError, "Unsupported provider: #{provider}"
        end
      end
    end
  end
end