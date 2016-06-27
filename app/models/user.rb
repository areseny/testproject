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
#   t.boolean  "super_user"
# end

class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable, :omniauthable
  include DeviseTokenAuth::Concerns::User

  has_many :recipes, inverse_of: :user
  has_many :conversion_chains, inverse_of: :user

  def super_user?
  	self.super_user
  end

  def is_admin?(organisation)
  	Membership.where(:organisation_id => organisation.id, :user_id => self.id, :admin => true).exists?
  end

  def administered_organisations
  	Membership.where(user_id => self.id, admin => true)
  end


end
