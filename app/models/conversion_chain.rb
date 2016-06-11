require 'conversion_errors/conversion_errors'
require 'yaml'

# create_table "conversion_chains", force: :cascade do |t|
#   t.integer  "user_id",           null: false
#   t.datetime "executed_at"
#   t.string   "input_file"
#   t.integer  "recipe_id", null: false
#   t.datetime "created_at",        null: false
#   t.datetime "updated_at",        null: false
# end

class ConversionChain < ActiveRecord::Base
  include ConversionErrors

  belongs_to :user
  belongs_to :recipe
  has_many :conversion_steps, inverse_of: :conversion_chain

  mount_uploader :input_file
  # mount_uploaders :files, FileUploader
  # has_many :files, as: :file_handler

  validates_presence_of :user, :recipe

  def retry_conversion!
    # file = File.open(input_file.file.file) # LOL
    recipe.clone_and_execute(input_file)
  end

  def execute_conversion!
    raise("Chain not saved yet") if self.new_record?
    raise ConversionErrors::NoFileSuppliedError.new("No input file received") unless input_file.present?
    self.update_attribute(:executed_at, Time.zone.now)
    ConversionWorker.perform_async(self.id)
  end

  def output_file
    return unless executed_at
    return unless conversion_steps.any?
    last_step.output_file
  end

  def last_step
    conversion_steps.sort_by(&:position).last
  end

  def step_classes
    recipe.recipe_steps.sort_by(&:position).inject([]) do |result, recipe_step|
      result << recipe_step.step_class.behaviour_class
    end
  end

  def map_results(runner, conversion_steps)
    runner.step_array.each_with_index do |runner_step, index|
      step_model = conversion_steps[index]
      step_model.conversion_errors = [runner_step.errors].flatten
      step_model.output_file = runner_step.output_files
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
    conversion_steps.each do |step|
      next if step.conversion_errors.nil?
      return false if YAML.load(step.conversion_errors).present?
    end
    true
  end

  def input_file_name
    input_file.path.split("/").last if input_file && input_file.path
  end

  def input_file_path
    Rails.application.routes.url_helpers.download_api_conversion_chain_url(self)
  end

  def output_file_name
    output_file.path.split("/").last if output_file && output_file.path
  end

  def output_file_path
    Rails.application.routes.url_helpers.download_api_conversion_step_url(last_step)
  end

end