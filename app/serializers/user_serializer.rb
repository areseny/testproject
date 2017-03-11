class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :nickname, :admin

  def admin
    object.is_admin?
  end
end
