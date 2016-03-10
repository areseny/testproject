class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :nickname
end
