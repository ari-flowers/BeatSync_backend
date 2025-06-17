# app/services/spotify_service.rb
require 'net/http'
require 'uri'
require 'json'

class SpotifyService
  BASE_URL = 'https://api.spotify.com/v1'

  def initialize(oauth_connection)
    @connection = oauth_connection
    raise ArgumentError, 'OAuth connection required' unless @connection

    refresh_token_if_expired!
    @access_token = @connection.reload.access_token
  end

  def fetch_user_profile
    get('/me')
  end

  def fetch_user_playlists
    get('/me/playlists')
  end

  def fetch_playlist(spotify_id)
    get("/playlists/#{spotify_id}")
  end

  private

  def refresh_token_if_expired!
    @connection.refresh_token_if_expired!
  end

  def get(path)
    uri = URI("#{BASE_URL}#{path}")
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{@access_token}"

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

    if res.code.to_i >= 400
      Rails.logger.warn "⚠️ Spotify API error (#{res.code}): #{res.body}"
      return nil
    end

    JSON.parse(res.body)
  rescue => e
    Rails.logger.error "❌ SpotifyService error: #{e.message}"
    nil
  end
end