# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170616111427) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_roles", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string  "role",       null: false
    t.index ["account_id", "role"], name: "index_account_roles_on_account_id_and_role", using: :btree
  end

  create_table "accounts", force: :cascade do |t|
    t.string   "provider",               default: "email", null: false
    t.string   "uid",                    default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "name"
    t.string   "nickname"
    t.string   "image"
    t.string   "email"
    t.json     "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_accounts_on_email", using: :btree
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree
    t.index ["uid", "provider"], name: "index_accounts_on_uid_and_provider", unique: true, using: :btree
  end

  create_table "process_chains", force: :cascade do |t|
    t.integer  "account_id",                        null: false
    t.datetime "executed_at"
    t.integer  "recipe_id",                         null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.datetime "finished_at"
    t.string   "slug"
    t.text     "input_file_list"
    t.json     "execution_parameters", default: {}, null: false
  end

  create_table "process_steps", force: :cascade do |t|
    t.integer  "process_chain_id",                  null: false
    t.integer  "position",                          null: false
    t.text     "notes"
    t.datetime "executed_at"
    t.text     "execution_errors"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "step_class_name",                   null: false
    t.string   "version"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.text     "output_file_list"
    t.boolean  "successful"
    t.json     "execution_parameters", default: {}, null: false
    t.index ["position", "process_chain_id"], name: "index_process_steps_on_position_and_process_chain_id", unique: true, using: :btree
  end

  create_table "recipe_steps", force: :cascade do |t|
    t.integer  "recipe_id",                         null: false
    t.integer  "position",                          null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "step_class_name",                   null: false
    t.json     "execution_parameters", default: {}, null: false
    t.index ["recipe_id", "position"], name: "chain_step_position_index", unique: true, using: :btree
  end

  create_table "recipes", force: :cascade do |t|
    t.integer  "account_id",                  null: false
    t.string   "name",                        null: false
    t.text     "description"
    t.boolean  "active",      default: true,  null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "public",      default: false, null: false
  end

  create_table "services", force: :cascade do |t|
    t.string   "name",        null: false
    t.string   "description"
    t.string   "auth_key"
    t.integer  "account_id",  null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["auth_key"], name: "index_services_on_auth_key", unique: true, using: :btree
  end

end
