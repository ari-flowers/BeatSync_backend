class UserConnectionSerializer < ActiveModel::Serializer
  attributes :id, :provider, :uid
end