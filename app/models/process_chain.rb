require 'execution_errors'
require 'yaml'
require 'ink_step/mixins/helper_methods'
require 'constants'

# create_table "process_chains", force: :cascade do |t|
  # t.integer  "user_id",     null: false
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

  belongs_to :user
  belongs_to :recipe, inverse_of: :process_chains
  has_many :process_steps, inverse_of: :process_chain, dependent: :destroy

  after_initialize do
    generate_unique_slug
  end

  before_save :generate_unique_slug

  validates_presence_of :user, :recipe

  scope :belongs_to_user, -> (user_id) { where(user_id: user_id) }

  def retry_execution!(current_api_user:)
    recipe.clone_and_execute(user: current_api_user, input_files: open_input_files)
  end

  def execute_process!(input_files:, callback_url: "")
    raise "Chain not saved yet" if new_record?
    raise ExecutionErrors::NoFileSuppliedError.new("No input file received") unless input_files.present?
    initialize_directories
    write_input_files(input_files)
    self.update_attribute(:executed_at, Time.zone.now)
    ExecutionWorker.perform_async(self.id, callback_url)
  end

  def last_step
    process_steps.sort_by(&:position).last
  end

  def step_classes
    process_steps.sort_by(&:position).map(&:step_class)
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

    self.input_file = input_files.map(&:original_filename)
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
    runner_steps.each_with_index do |runner_step, index|
      process_step = process_steps[index]
      process_step.execution_errors = [runner_step.errors].flatten
      ap "saving step #{process_step.step_class_name} v. #{version}"
      process_step.version = runner_step.version
      process_step.started_at = runner_step.started_at
      process_step.finished_at = runner_step.finished_at
      process_step.save!
    end
  end

  def successful?
    process_steps.each do |step|
      next if step.execution_errors.nil?
      return false if YAML.load(step.execution_errors).present?
    end
    true
  end

  def finished_at
    last_step.try(:finished_at)
  end

  def working_directory
    File.join(Constants::FILE_LOCATION, slug)
  end

  def input_files_directory
    File.join(working_directory, Constants::INPUT_FILE_DIRECTORY_NAME)
  end

  def input_file_list
    Dir.chdir(input_files_directory) do
      Dir.glob('**/*').select {|f| File.file? f}
    end
  end

  def open_input_files
    input_file_manifest.inject([]) do |list, file|
      list << UploadedFile.new(input_files_directory: input_files_directory, relative_path: file)
      list
    end
  end

  def write_output_file_manifest
    ap output_file_manifest
    raise "WRITE THIS METHOD!"
  end

  def write_input_file_manifest
    raise "WRITE THIS METHOD!"
  end

  def input_file_manifest
    recursive_file_list(input_files_directory)
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