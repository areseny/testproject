# create_table "conversion_steps", force: :cascade do |t|
#   t.integer  "executed_chain_id", null: false
#   t.integer  "position",          null: false
#   t.integer  "step_class_id",     null: false
#   t.text     "notes"
#   t.datetime "executed_at"
#   t.string   "output_file"
#   t.text     "conversion_errors"
#   t.datetime "created_at",        null: false
#   t.datetime "updated_at",        null: false
# end

class ConversionStep < ActiveRecord::Base

  belongs_to :step_class
  belongs_to :executed_chain, inverse_of: :conversion_steps

  validates_presence_of :executed_chain, :step_class, :position
  validates :position, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates_uniqueness_of :position, { scope: :executed_chain, message: "Only one step can be in this position for this chain" }



end