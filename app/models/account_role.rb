class AccountRole < ApplicationRecord

  belongs_to :account, inverse_of: :account_roles

  validates_presence_of :account, :role
  validates_uniqueness_of :role, { scope: :account, message: "this account already has this role" }

end