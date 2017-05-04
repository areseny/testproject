class Service < ApplicationRecord

  belongs_to :account

  validates :account, presence: true
  validates :name, presence: true

  delegate :provider, :email, :uid, to: :account

  # def generate_auth_token
  #   token = SecureRandom.hex
  #   self.update_columns(auth_token: token)
  #   token
  # end
  #
  # def invalidate_auth_token
  #   self.update_columns(auth_token: nil)
  # end

end