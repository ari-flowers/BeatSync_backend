class Playlist < ApplicationRecord
  belongs_to :oauth_connection
  has_many :tracks, dependent: :destroy
end