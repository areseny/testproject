# create_table "conversion_steps", force: :cascade do |t|
#   t.integer  "conversion_chain_id", null: false
#   t.integer  "position",          null: false
#   t.text     "notes"
#   t.datetime "executed_at"
#   t.string   "output_file"
#   t.text     "execution_errors"
#   t.datetime "created_at",        null: false
#   t.datetime "updated_at",        null: false
#   t.string   "step_class_name",   null: false
# end

class ConversionStep < ApplicationRecord
  belongs_to :conversion_chain, inverse_of: :conversion_steps

  has_many :files, as: :file_handler

  mount_uploader :output_file

  validates_presence_of :conversion_chain, :position, :step_class_name
  validates :position, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates_uniqueness_of :position, { scope: :conversion_chain, message: "Only one step can be in this position for this chain" }

  def step_class
    class_from_string(step_class_name)
  end

  def output_file_path
    Rails.application.routes.url_helpers.download_api_conversion_step_url(self)
  end

  def output_file_name
    output_file.path.split("/").last if output_file && output_file.path
  end

end