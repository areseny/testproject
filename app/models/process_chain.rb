require 'execution_errors'
require 'yaml'
require 'ink_step/mixins/helper_methods'
require 'constants'

# create_table "process_chains", force: :cascade do |t|
  # t.integer  "account_id",     null: false
  # t.datetime "executed_at"
  # t.string   "input_file"
  # t.integer  "recipe_id",   null: false
  # t.datetime "created_at",  null: false
  # t.datetime "updated_at",  null: false
  # t.datetime "finished_at"
  # t.string   "slug"
  # t.text     "input_file_manifest"
# end

class ProcessChain < ApplicationRecord
  include ExecutionErrors
  include SlugMethods
  include DirectoryMethods
  include EventConstants

  serialize :input_file_list

  belongs_to :account
  belongs_to :recipe, inverse_of: :process_chains
  has_many :process_steps, -> { order(:position) }, inverse_of: :process_chain, dependent: :destroy

  before_save :generate_unique_slug

  validates_presence_of :account, :recipe

  scope :belongs_to_account, -> (account_id) { where(account_id: account_id) }

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
    save_input_file_manifest!
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

  def write_input_files(input_files)
    # Input file is received by the controller like so
    #<ActionDispatch::Http::UploadedFile:0x007f2ad1984fd8
    # @tempfile=#<Tempfile:/tmp/RackMultipart20161211-6674-1d8irke.docx>,
    # @original_filename="a_very_nice_document.docx",
    # @content_type="application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    # @headers="Content-Disposition: form-data; name=\"input_file\"; filename=\"a_very_nice_document.docx\"\r\nContent-Type: application/vnd.openxmlformats-officedocument.wordprocessingml.document\r\n">

    input_files.each do |uploaded_file|
      target_file = File.join(input_files_directory, uploaded_file.original_filename)
      FileUtils.cp(uploaded_file.tempfile, target_file)
    end
  end

  def initialize_directories
    create_directory_if_needed(Constants::FILE_LOCATION)
    create_directory_if_needed(working_directory)
    create_directory_if_needed(input_files_directory)
    process_steps.each do |step|
      create_directory_if_needed(step.working_directory)
    end
  end

  def map_results(runner_steps)
    runner_steps.each do |runner_step|
      process_step = process_steps[runner_step.position-1]
      process_step.execution_errors = [runner_step.errors].flatten
      process_step.notes = [runner_step.notes].flatten
      process_step.version = runner_step.version
      process_step.started_at = runner_step.started_at
      process_step.finished_at = runner_step.finished_at
      process_step.successful = runner_step.successful
      process_step.output_file_list = assemble_manifest(process_step.working_directory)
      process_step.save!
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

  def open_input_files
    recursive_file_list(input_files_directory).inject([]) do |list, file|
      list << UploadedFile.new(input_files_directory: input_files_directory, relative_path: file)
      list
    end
  end

  def save_input_file_manifest!
    self.input_file_list = assemble_manifest(input_files_directory)
    save!
  end

  def input_file_manifest
    if input_file_list.present?
      input_file_list
    else
      save_input_file_manifest!
    end
  end

  def output_file_manifest
    last_step.output_file_manifest
  end

  def assemble_output_file_zip
    last_step.assemble_output_file_zip
  end

  def assemble_input_file_zip
    zip_path = "/tmp/chain_#{id}_input.zip"
    unless File.exists?(zip_path)
      `zip -rj "#{zip_path}" "#{input_files_directory}"`
    end
    zip_path
  end

end