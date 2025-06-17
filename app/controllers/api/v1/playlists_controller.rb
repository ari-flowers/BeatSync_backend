# app/controllers/api/v1/playlists_controller.rb
module Api
  module V1
    class PlaylistsController < BaseController
      before_action :set_oauth_service

      def index
        limit = (params[:limit] || 50).to_i
        offset = (params[:offset] || 0).to_i

        playlists = @oauth_service.get_user_playlists(limit: limit, offset: offset)

        if playlists[:error]
          render json: { error: playlists[:error] }, status: :bad_request
        else
          render json: {
            items: playlists[:items],
            total: playlists[:total],
            limit: playlists[:limit],
            offset: playlists[:offset],
            next: playlists[:next],
            previous: playlists[:previous]
          }
        end
      end

      def tracks
        playlist_id = params[:id]
        tracks_response = @oauth_service.get_playlist_tracks(playlist_id: playlist_id)
      
        if tracks_response[:error]
          render json: { error: tracks_response[:error] }, status: :bad_request
        else
          cleaned = tracks_response[:items].map do |item|
            track = item[:track]
            next unless track # Sometimes Spotify returns nil tracks
      
            {
              id: track[:id],
              name: track[:name],
              artists: track[:artists].map { |a| a[:name] },
              album: {
                name: track[:album][:name],
                image_url: track[:album][:images].first&.dig(:url)
              },
              duration_ms: track[:duration_ms],
              explicit: track[:explicit],
              spotify_url: track[:external_urls][:spotify],
              added_at: item[:added_at]
            }
          end.compact
      
          render json: { items: cleaned }
        end
      end

      private

      def set_oauth_service
        @oauth_service = Oauth::SpotifyService.new
      end
    end
  end
end