class OAuthConnection < ApplicationRecord
  serialize :extra_data, JSON
  scope :spotify, -> { find_by(provider: 'spotify') }

  def refresh_token_if_expired!
    return unless refresh_token.present?
    return if Time.now < expires_at

    uri = URI('https://accounts.spotify.com/api/token')
    res = Net::HTTP.post_form(uri, {
      grant_type: 'refresh_token',
      refresh_token: refresh_token,
      client_id: ENV['SPOTIFY_CLIENT_ID'],
      client_secret: ENV['SPOTIFY_CLIENT_SECRET']
    })

    data = JSON.parse(res.body)

    if res.code.to_i == 200 && data['access_token']
      update!(
        access_token: data['access_token'],
        expires_at: Time.now + data['expires_in'].to_i.seconds
      )
      Rails.logger.info "🔁 Spotify token refreshed successfully"
    else
      Rails.logger.error "⚠️ Failed to refresh Spotify token: #{res.body}"
    end
  rescue => e
    Rails.logger.error "🔥 Exception during Spotify token refresh: #{e.message}"
  end
end