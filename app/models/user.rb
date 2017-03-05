# create_table "users", force: :cascade do |t|
#   t.string   "provider",               default: "email", null: false
#   t.string   "uid",                    default: "",      null: false
#   t.string   "encrypted_password",     default: "",      null: false
#   t.string   "reset_password_token"
#   t.datetime "reset_password_sent_at"
#   t.datetime "remember_created_at"
#   t.integer  "sign_in_count",          default: 0,       null: false
#   t.datetime "current_sign_in_at"
#   t.datetime "last_sign_in_at"
#   t.string   "current_sign_in_ip"
#   t.string   "last_sign_in_ip"
#   t.string   "confirmation_token"
#   t.datetime "confirmed_at"
#   t.datetime "confirmation_sent_at"
#   t.string   "unconfirmed_email"
#   t.string   "name"
#   t.string   "nickname"
#   t.string   "image"
#   t.string   "email"
#   t.json     "tokens"
#   t.datetime "created_at"
#   t.datetime "updated_at"
# end

# needed as Devise uses this class before Rails has a chance to autoload it
require 'rails/generators/rails/app/templates/app/models/application_record'

class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable, :omniauthable
  include DeviseTokenAuth::Concerns::User

  has_many :recipes, inverse_of: :user
  has_many :process_chains, inverse_of: :user
  has_many :user_roles, inverse_of: :user

  def roles
    user_roles.map(&:role).uniq
  end

  def add_roles(roles_to_add)
    [roles_to_add].flatten.each do |role|
      user_roles.create(role: role) unless roles.include?(role)
    end
  end

end
