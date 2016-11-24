# create_table "process_steps", force: :cascade do |t|
#   t.integer  "process_chain_id", null: false
#   t.integer  "position",          null: false
#   t.text     "notes"
#   t.datetime "executed_at"
#   t.string   "output_file"
#   t.text     "execution_errors"
#   t.datetime "created_at",        null: false
#   t.datetime "updated_at",        null: false
#   t.string   "step_class_name",   null: false
# end

class ProcessStep < ApplicationRecord
  belongs_to :process_chain, inverse_of: :process_steps

  # has_many :files, as: :file_handler

  mount_uploader :output_file, FileUploader

  validates_presence_of :process_chain, :position, :step_class_name
  validates :position, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates_uniqueness_of :position, { scope: :process_chain, message: "Only one step can be in this position for this chain" }

  def step_class
    class_from_string(step_class_name)
  end

  def output_file_path
    Rails.application.routes.url_helpers.download_api_process_step_url(self)
  end

  def output_file_name
    output_file.identifier unless output_file.identifier.nil?
    output_file.path.split("/").last if output_file && output_file.path
  end

end