class AccountSerializer < ActiveModel::Serializer
  attributes :id, :email, :admin, :created_at, :last_sign_in_at, :confirmed_at, :name, :nickname

  def admin
    object.admin?
  end

end
