# app/services/oauth/spotify_service.rb
require 'faraday'

module Oauth
  class SpotifyService
    BASE_URL = 'https://api.spotify.com/v1'

    def initialize(user = nil)
      @connection = OAuthConnection.spotify
    end

    def auth_url
      query = {
        client_id: ENV['SPOTIFY_CLIENT_ID'],
        response_type: 'code',
        redirect_uri: redirect_uri,
        scope: 'user-read-email playlist-read-private',
        show_dialog: true
      }.to_query

      "https://accounts.spotify.com/authorize?#{query}"
    end

    def exchange_code_for_token(code)
      response = Faraday.post('https://accounts.spotify.com/api/token') do |req|
        req.headers['Authorization'] = basic_auth_header
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = {
          grant_type: 'authorization_code',
          code: code,
          redirect_uri: redirect_uri
        }.to_query
      end

      JSON.parse(response.body).with_indifferent_access
    end

    def fetch_user_profile(access_token)
      response = Faraday.get("#{BASE_URL}/me") do |req|
        req.headers['Authorization'] = "Bearer #{access_token}"
      end

      JSON.parse(response.body)
    end

    def active_token
      refresh_if_expired
      @connection.access_token
    end

    def get_user_playlists(limit: 50, offset: 0)
      refresh_if_expired
      all_items = []
      current_offset = offset

      loop do
        response = Faraday.get("#{BASE_URL}/me/playlists?limit=#{limit}&offset=#{current_offset}") do |req|
          req.headers['Authorization'] = "Bearer #{@connection.access_token}"
        end

        parsed = JSON.parse(response.body).with_indifferent_access
        return parsed if parsed[:error]

        all_items.concat(parsed[:items])
        break unless parsed[:next]

        current_offset += limit
      end

      {
        items: all_items,
        total: all_items.size,
        limit: limit,
        offset: offset,
        next: nil,
        previous: nil
      }
    end

    def get_playlist_tracks(playlist_id:, limit: 100, offset: 0)
      refresh_if_expired
      all_items = []
      current_offset = offset

      loop do
        url = "#{BASE_URL}/playlists/#{playlist_id}/tracks?limit=#{limit}&offset=#{current_offset}"
        response = Faraday.get(url) do |req|
          req.headers['Authorization'] = "Bearer #{@connection.access_token}"
        end

        parsed = JSON.parse(response.body).with_indifferent_access
        return parsed if parsed[:error]

        all_items.concat(parsed[:items])
        break unless parsed[:next]

        current_offset += limit
      end

      {
        items: all_items,
        total: all_items.size,
        limit: limit,
        offset: offset,
        next: nil,
        previous: nil
      }
    end

    private

    def refresh_if_expired
      return unless @connection.expires_at && Time.current >= @connection.expires_at

      response = Faraday.post('https://accounts.spotify.com/api/token') do |req|
        req.headers['Authorization'] = basic_auth_header
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = {
          grant_type: 'refresh_token',
          refresh_token: @connection.refresh_token
        }.to_query
      end

      token_data = JSON.parse(response.body)
      @connection.update!(
        access_token: token_data['access_token'],
        expires_at: Time.current + token_data['expires_in'].to_i.seconds
      )
    end

    def redirect_uri
      "#{ENV['API_BASE_URL']}/api/v1/auth/spotify/callback"
    end

    def basic_auth_header
      credentials = "#{ENV['SPOTIFY_CLIENT_ID']}:#{ENV['SPOTIFY_CLIENT_SECRET']}"
      "Basic #{Base64.strict_encode64(credentials)}"
    end
  end
end