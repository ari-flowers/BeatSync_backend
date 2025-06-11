class PlaylistSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :user_id
  has_many :tracks
end