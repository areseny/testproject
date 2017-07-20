require 'execution_errors'
require 'sidekiq/api'

class Recipe < ApplicationRecord
  include ExecutionErrors

  belongs_to :account, inverse_of: :recipes
  has_many :recipe_steps, -> { order(:position) }, inverse_of: :recipe, dependent: :destroy
  has_many :process_chains, -> { order(created_at: :desc)}, inverse_of: :recipe, dependent: :destroy

  has_many :my_process_chains, -> (current_entity) {
    where(account_id: current_entity.account.id).order(created_at: :desc)
  }, inverse_of: :recipe, class_name: ProcessChain

  validates_presence_of :name, :account
  validates_inclusion_of :active, :in => [true, false]
  validates_inclusion_of :public, :in => [true, false]
  validate :steps_have_unique_positions, :steps_contiguous?
  validates_presence_of :recipe_steps, message: ->(object, data) { "- Please add at least one recipe step" }

  after_initialize :set_as_active

  scope :active, -> { where(active: true) }

  scope :available_to_account, -> (account_id, admin) {
    if admin
      all
    else
      active.where("PUBLIC = ? OR ACCOUNT_ID = ?", true, account_id)
    end
  }

  def available_process_chains(current_entity)
    if current_entity.admin?
      ProcessChain.order(created_at: :desc)
    else
      ProcessChain.where(account_id: current_entity.account.id).order(created_at: :desc)
    end
  end

  def check_for_empty_steps
    raise ExecutionErrors::NoStepsError.new("No steps specified - please add some steps to the recipe and try again.") if recipe_steps.count < 1
  end

  def check_for_input_file(input_files)
    raise ExecutionErrors::NoFileSuppliedError.new unless input_files.present?
  end

  def attempt_to_destroy!(current_entity)
    if current_entity.admin?
      destroy
    else
      if account != current_entity.account
        ap "Does it belong to this user? #{current_entity.account.email}"
        ap account != current_entity.account
        raise RuntimeError.new("Can't destroy this recipe - it is not yours")
      elsif (process_chains.map(&:account_id) - [current_entity.account.id]).any?
        ap "Does it have process chains not belonging to them?"
        ap process_chains.map(&:account_id)
        ap (process_chains.map(&:account_id) - [current_entity.account.id])
        ap (process_chains.map(&:account_id) - [current_entity.account.id]).any?
        raise RuntimeError.new("Can't delete this recipe, because it has process chains that aren't yours.")
      else
        destroy
      end
    end
  end

  def prepare_for_execution(input_files:, account:, execution_parameters: {})
    check_for_empty_steps
    check_for_input_file([input_files].flatten)
    new_chain = clone_to_process_chain(account: account, execution_parameters: execution_parameters)
    new_chain.save!
    new_chain
  end

  def clone_to_process_chain(account:, execution_parameters: {})
    new_chain = process_chains.new(account: account, execution_parameters: execution_parameters)
    recipe_steps.each do |recipe_step|
      raw_params = execution_parameters[recipe_step.position.to_s] || {}
      parameters = raw_params["data"] || {}

      combined_parameters = recipe_step.execution_parameters.merge(parameters)
      new_chain.process_steps.new(position: recipe_step.position,
                                  step_class_name: recipe_step.step_class_name,
                                  execution_parameters: combined_parameters)
    end
    new_chain
  end

  def generate_recipe_steps(data)
    generate_steps_with_positions(data[:steps_with_positions]) if data[:steps_with_positions].present?
    generate_steps(data[:steps]) if data[:steps].present?
  end

  def times_executed(account_id=nil)
    return process_chains.count unless account_id
    process_chains.belongs_to_account(account_id).count
  end

  def ensure_step_installation
    missing_steps = []
    recipe_steps.each do |step|
      missing_steps << step.step_class_name if step.step_class.nil?
    end

    if missing_steps.any?
      error = StepNotInstalledError.new
      error.missing_step_classes = missing_steps
      raise error
    end
  end

  def execute_recipe_in_progress?
    Sidekiq::Workers.new.each do |process_id, thread_id, work|
      return true if work['payload']['args'].include?(self.id)
      # process_id is a unique identifier per Sidekiq process
      # thread_id is a unique identifier per thread
      # work is a Hash which looks like:
      # { 'queue' => name, 'run_at' => timestamp, 'payload' => msg }
      # run_at is an epoch Integer.
      # payload is a Hash which looks like:
      # { 'retry' => true,
      #   'queue' => 'default',
      #   'class' => 'Redacted',
      #   'args' => [1, 2, 'foo'],
      #   'jid' => '80b1e7e46381a20c0c567285',
      #   'enqueued_at' => 1427811033.2067106 }
    end

    Sidekiq::Queue.new.each do |job|
      return true if job.args.include?(self.id)
    end
    false
  end

  private

  def generate_steps_with_positions(recipe_step_data)
    # [ {position: 1, name: "InkStep::DocxToXml"}, {position: 2, name: "InkStep::XmlToHtml" } ]
    return unless recipe_step_data.present?
    recipe_step_data.each do |st|
      recipe_steps.new(position: st[:position], step_class_name: st[:step_class_name])
    end
  end

  def generate_steps(recipe_step_data)
    # expecting this format:
    # [ "InkStep::DocxToXml", "InkStep::XmlToHtml" ]
    return unless recipe_step_data.present?
    count = 0
    recipe_step_data.each do |step_class_name|
      count += 1
      recipe_steps.new(position: count, step_class_name: step_class_name)
    end
  end

  def set_as_active
    attributes[:active] = true if active.nil?
  end

  def steps_have_unique_positions
    # necessary since it's possible none will have been committed to the db yet!

    positions = recipe_steps.map(&:position)
    duplicates = positions.detect{ |e| positions.count(e) > 1 }
    errors.add(:recipe_step_positions, "must be unique") if duplicates
  end

  def steps_contiguous?
    array = recipe_steps.map(&:position)
    contiguous = array.sort.each_cons(2).all? { |x,y| y == x + 1 }
    errors.add(:recipe_step_positions, "must be contiguous") unless contiguous
  end
end