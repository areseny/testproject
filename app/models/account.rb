# needed as Devise uses this class before Rails has a chance to autoload it
require 'rails/generators/rails/app/templates/app/models/application_record'

class Account < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable,
         :trackable, :validatable
          # :confirmable, :omniauthable
  include DeviseTokenAuth::Concerns::User

  has_many :recipes, inverse_of: :account
  has_many :process_chains, inverse_of: :account
  has_many :account_roles, inverse_of: :account
  has_many :recipe_favourites, inverse_of: :account
  has_many :recipe_step_presets, inverse_of: :account
  has_one :service

  def roles
    account_roles.map(&:role).uniq
  end

  def add_roles(roles_to_add)
    [roles_to_add].flatten.each do |role|
      account_roles.create(role: role) unless roles.include?(role)
    end
  end

  def admin?
    roles.include?("admin")
  end

  # jwt

  def account
    self
  end

  def new_jwt
    {'access-token' => generate_token}
  end

  def uid
    email
  end

  def generate_token
    JsonWebToken.encode({account_id: account.id})
  end
end
