require 'execution_errors'
require 'yaml'
require 'ink_step/mixins/helper_methods'
require 'constants'

class ProcessChain < ApplicationRecord
  include ExecutionErrors
  include SlugMethods
  include DirectoryMethods
  include EventConstants
  include DownloadableMethods

  serialize :input_file_list

  belongs_to :account
  belongs_to :recipe, inverse_of: :process_chains
  has_many :process_steps, -> { order(:position) }, inverse_of: :process_chain, dependent: :destroy

  before_save :generate_unique_slug

  validates_presence_of :account, :recipe

  scope :belongs_to_account, -> (account_id) { where(account_id: account_id) }

  scope :available_process_chains, -> (current_entity) {
    if current_entity.admin?
      order(created_at: :desc)
    else
      where(account_id: current_entity.account.id).order(created_at: :desc)
    end
  }

  def retry_execution!(current_entity:)
    files = open_input_files
    new_chain = recipe.prepare_for_execution(account: current_entity.account, input_files: files)
    new_chain.execute_process!(callback_url: "", input_files: files)
    new_chain
  end

  def execute_process!(input_files:, callback_url: "")
    raise "Chain not saved yet" if new_record?
    raise ExecutionErrors::NoFileSuppliedError.new("No input files received") unless input_files.present?
    initialize_directories
    write_input_files(input_files)
    ExecutionWorker.perform_async(self.id, callback_url)
  end

  def last_step
    process_steps.sort_by(&:position).last
  end

  def finished?
    !!finished_at
  end

  def started?
    !!started_at
  end

  def step_classes
    process_steps_in_order.map(&:step_class)
  end

  def process_steps_in_order
    process_steps.sort_by(&:position)
  end

  def initialize_directories
    create_directory_if_needed(Constants::FILE_LOCATION)
    create_directory_if_needed(working_directory)
    create_directory_if_needed(input_files_directory)
    process_steps.each do |step|
      create_directory_if_needed(step.working_directory)
    end
  end

  def successful?
    process_steps.each do |step|
      return false unless step.successful
    end
    true
  end

  def working_directory
    File.join(Constants::FILE_LOCATION, slug)
  end

  def input_files_directory
    File.join(working_directory, Constants::INPUT_FILE_DIRECTORY_NAME)
  end

  def zip_path
    "/tmp/chain_#{id}_input.zip"
  end
end