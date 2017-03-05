class UserRole < ApplicationRecord

  belongs_to :user, inverse_of: :user_roles

  validates_presence_of :user, :role
  validates_uniqueness_of :role, { scope: :user, message: "this user already has this role" }

end