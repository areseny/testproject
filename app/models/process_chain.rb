require 'execution_errors'
require 'yaml'

# create_table "process_chains", force: :cascade do |t|
#   t.integer  "user_id",           null: false
#   t.datetime "executed_at"
#   t.string   "input_file"
#   t.integer  "recipe_id", null: false
#   t.datetime "created_at",        null: false
#   t.datetime "updated_at",        null: false
# end

class ProcessChain < ApplicationRecord
  include ExecutionErrors

  belongs_to :user
  belongs_to :recipe, inverse_of: :process_chains
  has_many :process_steps, inverse_of: :process_chain, dependent: :destroy

  mount_uploader :input_file
  # mount_uploaders :files, FileUploader
  # has_many :files, as: :file_handler

  validates_presence_of :user, :recipe

  scope :belongs_to_user, -> (user_id) { where(user_id: user_id) }

  def retry_execution!(current_api_user:)
    # file = File.open(input_file.file.file) # LOL
    recipe.clone_and_execute(input_file: input_file, user: current_api_user)
  end

  def execute_process!
    raise("Chain not saved yet") if self.new_record?
    raise ExecutionErrors::NoFileSuppliedError.new("No input file received") unless input_file.present?
    self.update_attribute(:executed_at, Time.zone.now)
    ExecutionWorker.perform_async(self.id)
  end

  def output_file
    return unless executed_at
    return unless process_steps.any?
    last_step.output_file
  end

  def last_step
    process_steps.sort_by(&:position).last
  end

  def step_classes
    recipe.recipe_steps.sort_by(&:position).map(&:step_class)
  end

  def map_results(runner, process_steps)
    runner.step_array.each_with_index do |runner_step, index|
      step_model = process_steps[index]
      step_model.execution_errors = [runner_step.errors].flatten
      step_model.output_file = runner_step.output_files
      step_model.version = runner_step.version
      # if runner_step.output_files.respond_to(:map)
      #   step_model.output_file = runner_step.output_files.map(&:open)
      # elsif runner_step.output_files.respond_to(:open)
      #   step_model.output_file = runner_step.output_files.open
      # end
      step_model.save!
    end
  end

  def open_file(file_uploader)
    file_uploader.read
  rescue => e
    nil
  end

  def successful?
    process_steps.each do |step|
      next if step.execution_errors.nil?
      return false if YAML.load(step.execution_errors).present?
    end
    true
  end

  def input_file_name
    input_file.path.split("/").last if input_file && input_file.path
  end

  def input_file_path
    Rails.application.routes.url_helpers.download_api_process_chain_url(self)
  end

  def output_file_name
    output_file.path.split("/").last if output_file && output_file.path
  end

  def output_file_path
    raise "No process steps" if last_step.nil?
    Rails.application.routes.url_helpers.download_api_process_step_url(last_step)
  end

end