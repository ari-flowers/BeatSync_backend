module Oauth
  class SpotifyPlaylistSyncService
    BASE_URL = 'https://api.spotify.com/v1'

    def initialize(oauth_connection)
      @oauth_connection = oauth_connection
      @token = refresh_if_expired
    end

    def sync_all_playlists
      url = "#{BASE_URL}/me/playlists?limit=50"
      while url
        response = get(url)
        data = JSON.parse(response.body).with_indifferent_access
        data[:items].each { |item| upsert_playlist(item) }
        url = data[:next]
      end
    end

    private

    def get(url)
      Faraday.get(url) do |req|
        req.headers['Authorization'] = "Bearer #{@token}"
      end
    end

    def upsert_playlist(data)
      Playlist.find_or_initialize_by(spotify_id: data[:id]).tap do |playlist|
        playlist.oauth_connection = @oauth_connection
        playlist.name = data[:name]
        playlist.image_url = data[:images].first&.dig(:url)
        playlist.external_url = data[:external_urls][:spotify]
        playlist.total_tracks = data[:tracks][:total]
        playlist.save!
      end
    end

    def refresh_if_expired
      if @oauth_connection.expires_at && Time.current >= @oauth_connection.expires_at
        token_data = Faraday.post('https://accounts.spotify.com/api/token') do |req|
          req.headers['Authorization'] = basic_auth_header
          req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
          req.body = {
            grant_type: 'refresh_token',
            refresh_token: @oauth_connection.refresh_token
          }.to_query
        end

        parsed = JSON.parse(token_data.body)
        @oauth_connection.update!(
          access_token: parsed['access_token'],
          expires_at: Time.current + parsed['expires_in'].to_i.seconds
        )
      end

      @oauth_connection.access_token
    end

    def basic_auth_header
      creds = "#{ENV['SPOTIFY_CLIENT_ID']}:#{ENV['SPOTIFY_CLIENT_SECRET']}"
      "Basic #{Base64.strict_encode64(creds)}"
    end
  end
end