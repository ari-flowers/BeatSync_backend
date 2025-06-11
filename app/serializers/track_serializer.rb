class TrackSerializer < ActiveModel::Serializer
  attributes :id, :title, :artist, :album, :playlist_id
end