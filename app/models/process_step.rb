# create_table "process_steps", force: :cascade do |t|
#   t.integer  "process_chain_id",     null: false
#   t.integer  "position",             null: false
#   t.text     "notes"
#   t.datetime "executed_at"
#   t.string   "output_file"
#   t.text     "execution_errors"
#   t.datetime "created_at",           null: false
#   t.datetime "updated_at",           null: false
#   t.string   "step_class_name",      null: false
#   t.string   "version"
#   t.datetime "started_at"
#   t.datetime "finished_at"
#   t.text     "output_file_manifest"
# end

class ProcessStep < ApplicationRecord
  include ObjectMethods
  include DirectoryMethods

  belongs_to :process_chain, inverse_of: :process_steps

  validates_presence_of :process_chain, :position, :step_class_name
  validates :position, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates_uniqueness_of :position, { scope: :process_chain, message: "Only one step can be in this position for this chain" }

  def step_class
    class_from_string(step_class_name)
  end

  def working_directory
    File.join(process_chain.working_directory, position.to_s)
  end

  def output_files_location
    working_directory
  end

  def output_file_manifest
    assemble_manifest(working_directory)
  end

  def assemble_output_file_zip
    zip_path = "/tmp/step_#{id}_output.zip"
    unless File.exists?(zip_path)
      `zip -rj "#{zip_path}" "#{working_directory}"`
    end
    zip_path
  end
end