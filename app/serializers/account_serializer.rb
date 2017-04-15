class AccountSerializer < ActiveModel::Serializer
  attributes :id, :email, :admin

  def admin
    object.is_admin?
  end
end
