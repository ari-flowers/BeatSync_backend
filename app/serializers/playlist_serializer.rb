class PlaylistSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :spotify_id, :image_url, :is_public
  has_many :tracks
end