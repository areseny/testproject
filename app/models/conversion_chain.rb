require 'conversion_errors/conversion_errors'

# create_table "conversion_chains", force: :cascade do |t|
#   t.integer  "user_id",           null: false
#   t.datetime "executed_at"
#   t.string   "input_file"
#   t.integer  "chain_template_id", null: false
#   t.datetime "created_at",        null: false
#   t.datetime "updated_at",        null: false
# end

class ConversionChain < ActiveRecord::Base
  include ConversionErrors

  belongs_to :user
  belongs_to :chain_template
  has_many :conversion_steps, inverse_of: :conversion_chain

  mount_uploader :input_file
  # mount_uploaders :files, FileUploader
  # has_many :files, as: :file_handler

  validates_presence_of :user, :chain_template

  def execute_conversion!
    raise ConversionErrors::NoFileSuppliedError("No input file received") unless input_file.present?
    self.update_attribute(:executed_at, Time.zone.now)
    runner = Conversion::ChainExecutionRunner.new(step_classes)
    runner.run!(input_file)
    map_errors(runner, conversion_steps.sort_by(&:position))
  end

  def input_file_name
    input_file.name
  rescue => e
    "cannot render name"
  end

  def output_file
    return unless executed_at
    return unless conversion_steps.any?
    conversion_steps.sort_by(&:position).last.output_file
  end

  def step_classes
    chain_template.step_templates.sort_by(&:position).inject([]) do |result, step_template|
      result << step_template.step_class.behaviour_class
    end
  end

  def map_errors(runner, conversion_steps)
    runner.step_array.each_with_index do |runner_step, index|
      step_model = conversion_steps[index]
      step_model.conversion_errors = runner_step.errors
      step_model.save
    end
  end

end