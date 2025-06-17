module Api
  module V1
    class PlaylistsController < BaseController
      before_action :set_oauth_service

      def index
        limit = (params[:limit] || 50).to_i
        offset = (params[:offset] || 0).to_i

        playlists_response = @oauth_service.get_user_playlists(limit: limit, offset: offset)

        if playlists_response[:error]
          render json: { error: playlists_response[:error] }, status: :bad_request
        else
          cleaned_playlists = playlists_response[:items].map do |playlist|
            {
              id: playlist[:id],
              name: playlist[:name],
              description: playlist[:description],
              image_url: playlist[:images]&.first&.dig(:url),
              track_count: playlist[:tracks][:total],
              spotify_url: playlist[:external_urls][:spotify]
            }
          end

          render json: {
            items: cleaned_playlists,
            total: playlists_response[:total],
            limit: playlists_response[:limit],
            offset: playlists_response[:offset],
            next: playlists_response[:next],
            previous: playlists_response[:previous]
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

            duration_ms = track[:duration_ms]
            minutes = duration_ms / 60000
            seconds = (duration_ms % 60000) / 1000

            {
              id: track[:id],
              name: track[:name],
              artists: track[:artists].map do |artist|
                {
                  id: artist[:id],
                  name: artist[:name],
                  uri: artist[:uri],
                  spotify_url: artist[:external_urls][:spotify]
                }
              end,
              album: {
                id: track[:album][:id],
                name: track[:album][:name],
                release_date: track[:album][:release_date],
                total_tracks: track[:album][:total_tracks],
                album_type: track[:album][:album_type],
                image_url: track[:album][:images]&.first&.dig(:url),
                spotify_url: track[:album][:external_urls][:spotify]
              },
              duration_ms: duration_ms,
              duration: format("%d:%02d", minutes, seconds),
              explicit: track[:explicit],
              spotify_url: track[:external_urls][:spotify],
              added_at: item[:added_at],
              added_at_pretty: Time.parse(item[:added_at]).strftime("%b %d, %Y")
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