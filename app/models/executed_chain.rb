# create_table "executed_chains", force: :cascade do |t|
#   t.integer  "user_id",           null: false
#   t.datetime "executed_at"
#   t.string   "input_file"
#   t.integer  "chain_template_id", null: false
#   t.datetime "created_at",        null: false
#   t.datetime "updated_at",        null: false
# end

class ExecutedChain < ActiveRecord::Base

  belongs_to :user
  belongs_to :chain_template
  has_many :conversion_steps, inverse_of: :executed_chain

  validates_presence_of :user, :chain_template

end