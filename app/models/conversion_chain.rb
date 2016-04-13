require 'conversion_errors/conversion_errors'

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

  def execute_conversion!
    raise ConversionErrors::NoFileSuppliedError("No input file received") unless input_file.present?
    self.update_attribute(:executed_at, Time.zone.now)
    runner = Conversion::RecipeExecutionRunner.new(step_classes)
    runner.run!(input_file)
    map_errors(runner, conversion_steps.sort_by(&:position))
  end

  def output_file
    return unless executed_at
    return unless conversion_steps.any?
    conversion_steps.sort_by(&:position).last.output_file
  end

  def step_classes
    recipe.recipe_steps.sort_by(&:position).inject([]) do |result, recipe_step|
      result << recipe_step.step_class.behaviour_class
    end
  end

  def map_errors(runner, conversion_steps)
    runner.step_array.each_with_index do |runner_step, index|
      step_model = conversion_steps[index]
      step_model.conversion_errors = runner_step.errors
      step_model.output_file = runner_step.output_files
      step_model.save
    end
  end

  def successful?
    conversion_steps.each do |step|
      return false if step.conversion_errors.present?
    end
    true
  end


  def input_file_name
    input_file.path.split("/").last if input_file && input_file.path
  end

  def input_file_path
    "#{input_file.store_dir}/#{input_file_name}" if input_file && input_file.path
  end

  def output_file_name
    output_file.path.split("/").last if output_file && output_file.path
  end

  def output_file_path
    "#{output_file.store_dir}/#{output_file_name}" if output_file && output_file.path
  end

end