class SingleStepExecution < ApplicationRecord
  include ObjectMethods
  include DirectoryMethods
  include SlugMethods
  include DownloadableMethods

  serialize :output_file_list

  belongs_to :account, inverse_of: :single_step_executions

  validates_presence_of :account, :description
  before_save :generate_unique_slug

  # def output_file_manifest
  #   if !finished?
  #     []
  #   elsif output_file_list.present?
  #     output_file_list
  #   elsif File.exists?(working_directory)
  #     assemble_manifest(directory: working_directory)
  #   else
  #     # @TODO flag an error to admin!
  #     # ap "Cannot find file location for process step id '#{self.id}', chain id '#{process_chain_id}' and recipe id '#{process_chain.recipe_id}'"
  #     ap "Looking in #{working_directory}"
  #     []
  #   end
  # end

  def working_directory
    File.join(Constants::FILE_LOCATION, "single_step_executions", slug)
  end

  def start_execution!(code:, callback_url: nil)
    initialize_directories
    write_code_to_file(code: code)
    StandaloneExecutionWorker.perform_async(self.id, callback_url)
  end

  def code_file_name
    "#{step_class_name.split("::").last.underscore}.rb"
  end

  def code_file_location
    File.join(working_directory, code_file_name)
  end

  def write_code_to_file(code:)
    the_file = File.new(code_file_location, 'w+')
    the_file.write(code)
    the_file.close
    ap "wrote code to #{code_file_location}"
  end

  def output_files_location
    working_directory
  end

  def finished?
    !!finished_at
  end

  def started?
    !!executed_at
  end

  def step_class
    class_from_string(step_class_name)
  end

  def initialize_directories
    create_directory_if_needed(Constants::FILE_LOCATION)
    create_directory_if_needed(working_directory)
    create_directory_if_needed(input_files_directory)
    create_directory_if_needed(output_files_directory)
  end

  def input_files_directory
    File.join(working_directory, Constants::INPUT_FILE_DIRECTORY_NAME)
  end

  def output_files_directory
    File.join(working_directory, Constants::OUTPUT_FILE_DIRECTORY_NAME)
  end

  def assemble_output_file_zip
    zip_path = "/tmp/step_#{id}_output.zip"
    Dir.chdir(working_directory) do
      unless File.exists?(zip_path)
        `zip -r "#{zip_path}" *`
      end
    end
    zip_path
  end

  def process_log_file_name
    "process_step_#{self.id}.log"
  end

  def map_results(behaviour_step:)
    self.execution_errors = [behaviour_step.errors].flatten.map{|line| line.gsub(working_directory, "$process_step_working_directory")}
    self.notes = [behaviour_step.notes].flatten.map{|line| line.gsub(working_directory, "$process_step_working_directory")}
    self.executed_at = behaviour_step.executed_at
    self.finished_at = behaviour_step.finished_at
    self.successful = behaviour_step.successful
    self.output_file_list = behaviour_step.semantically_tagged_manifest
    self.process_log = behaviour_step.process_log
    save!
  end

end