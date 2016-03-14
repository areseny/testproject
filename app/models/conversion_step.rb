# create_table "conversion_steps", force: :cascade do |t|
#   t.integer  "conversion_chain_id", null: false
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
  belongs_to :conversion_chain, inverse_of: :conversion_steps

  has_many :files, as: :file_handler

  validates_presence_of :conversion_chain, :step_class, :position
  validates :position, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates_uniqueness_of :position, { scope: :conversion_chain, message: "Only one step can be in this position for this chain" }

  def step_class_name
    step_class.name
  end

end