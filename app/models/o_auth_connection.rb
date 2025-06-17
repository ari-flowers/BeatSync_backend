# app/models/oauth_connection.rb
class OAuthConnection < ApplicationRecord
  validates :provider, :uid, :access_token, presence: true

  scope :spotify, -> { find_by(provider: 'spotify') }

  # Returns true if the access token is expired
  def expired?
    expires_at.present? && Time.now >= expires_at
  end

  # Refreshes the token if it's expired
  def refresh_token_if_expired!
    return unless expired?

    unless refresh_token.present?
      Rails.logger.warn "⛔ Missing refresh token for #{provider} (uid: #{uid})"
      return
    end

    uri = URI('https://accounts.spotify.com/api/token')
    res = Net::HTTP.post_form(uri, {
      grant_type: 'refresh_token',
      refresh_token: refresh_token,
      client_id: ENV['SPOTIFY_CLIENT_ID'],
      client_secret: ENV['SPOTIFY_CLIENT_SECRET']
    })

    body = JSON.parse(res.body)

    if res.code.to_i == 200 && body['access_token']
      update!(
        access_token: body['access_token'],
        expires_at: Time.now + body['expires_in'].to_i.seconds
      )
      Rails.logger.info "✅ Spotify token refreshed for uid #{uid}"
    else
      Rails.logger.error "❌ Failed to refresh Spotify token: #{body.inspect}"
    end
  end
end