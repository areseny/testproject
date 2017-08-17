# create_table "process_steps", force: :cascade do |t|
#   t.integer  "process_chain_id",                  null: false
#   t.integer  "position",                          null: false
#   t.text     "notes"
#   t.datetime "executed_at"
#   t.text     "execution_errors"
#   t.datetime "created_at",                        null: false
#   t.datetime "updated_at",                        null: false
#   t.string   "step_class_name",                   null: false
#   t.string   "version"
#   t.datetime "started_at"
#   t.datetime "finished_at"
#   t.text     "output_file_list"
#   t.boolean  "successful"
#   t.json     "execution_parameters", default: {}, null: false
# end

class ProcessStep < ApplicationRecord
  include ObjectMethods
  include DirectoryMethods

  serialize :output_file_list

  belongs_to :process_chain, inverse_of: :process_steps

  validates_presence_of :process_chain, :position, :step_class_name
  validates :position, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates_uniqueness_of :position, { scope: :process_chain, message: "Only one step can be in this position for this chain" }

  def step_class
    class_from_string(step_class_name)
  end

  def output_file_manifest
    if output_file_list.present?
      output_file_list
    elsif File.exists?(working_directory)
      assemble_manifest(directory: working_directory)
    else
      # @TODO flag an error to admin!
      ap "Cannot find file location for process step id '#{self.id}', chain id '#{process_chain_id}' and recipe id '#{process_chain.recipe_id}'"
      ap "Looking in #{working_directory}"
    end
  end

  def working_directory
    File.join(process_chain.working_directory, position.to_s)
  end

  def output_files_location
    working_directory
  end

  def finished?
    !!finished_at
  end

  def started?
    !!started_at
  end

  def assemble_output_file_zip
    zip_path = "/tmp/step_#{id}_output.zip"
    unless File.exists?(zip_path)
      `zip -rj "#{zip_path}" "#{working_directory}"`
    end
    zip_path
  end

  def process_log_file_name
    "process_step_#{self.id}.log"
  end

  def map_results(behaviour_step:)
    self.execution_errors = [behaviour_step.errors].flatten.map{|line| line.gsub(working_directory, "$process_step_working_directory")}
    self.notes = [behaviour_step.notes].flatten.map{|line| line.gsub(working_directory, "$process_step_working_directory")}
    self.version = behaviour_step.version
    self.started_at = behaviour_step.started_at
    self.finished_at = behaviour_step.finished_at
    self.successful = behaviour_step.successful
    self.output_file_list = behaviour_step.semantically_tagged_manifest
    self.process_log = generate_process_log(behaviour_step.process_log)
    save!
  end

  def generate_process_log(message_array)
    new_array = []
    message_array.each do |line|
      new_line = line.gsub(process_chain.working_directory, "$process_chain_working_directory")
      new_array << new_line
    end
    new_array
  end
end