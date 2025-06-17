module Api
  module V1
    class TracksController < BaseController
      before_action :set_oauth_service

      def index
        playlist_id = params[:playlist_id]
        limit = params[:limit]&.to_i || 50
        offset = params[:offset]&.to_i || 0

        if playlist_id.blank?
          return render json: { error: 'Missing playlist_id' }, status: :bad_request
        end

        track_data = @oauth_service.get_playlist_tracks(
          playlist_id: playlist_id,
          limit: limit,
          offset: offset
        )

        if track_data[:error]
          render json: { error: track_data[:error] }, status: :bad_request
        else
          render json: track_data
        end
      end

      private

      def set_oauth_service
        provider = params[:provider] || 'spotify'
        connection = OAuthConnection.find_by(provider: provider)

        unless connection&.access_token
          render json: { error: "#{provider.titleize} not connected" }, status: :unauthorized and return
        end

        @oauth_service =
          case provider
          when 'spotify'
            ::Oauth::SpotifyService.new
          else
            render json: { error: 'Unsupported provider' }, status: :bad_request and return
          end
      end
    end
  end
end