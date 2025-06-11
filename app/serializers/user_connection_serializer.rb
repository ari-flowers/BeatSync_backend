class UserConnectionSerializer < ActiveModel::Serializer
  attributes :id, :provider, :uid, :user_id
end