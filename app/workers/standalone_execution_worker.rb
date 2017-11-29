$main_binding = binding

require 'httparty'
require 'open3'

class StandaloneExecutionWorker
  include Sidekiq::Worker
  include EventConstants
  include DirectoryMethods
  include ObjectMethods
  include ExecutionErrors

  sidekiq_options retry: false

  def perform(standalone_id, callback_url)
    ap "Performing standalone"
    sleep(5) unless Rails.env.test? # icky hack to solve race condition - not final solution

    @single_step_execution = SingleStepExecution.find(standalone_id)

    # load klass here
    klass = load_klass

    runner = Execution::StandaloneExecutionRunner.new(klass: klass, single_step_execution: @single_step_execution)
    begin
      runner.run!
    rescue => e
      ap e.message
      ap e.backtrace
      raise e
    ensure
      post_to_callback(callback_url)
    end
  end

  def post_to_callback(callback_url)
    return unless callback_url.present?
    begin
      HTTParty.post(callback_url,
                    :body => serialized_execution,
                    :headers => { 'Content-Type' => 'application/json' } )
    rescue => e
      ap "Could not post to callback URL #{callback_url}"
      ap "#{e.message}"
      ap "#{e.backtrace}"
    end
  end

  def load_klass
    klass_name = @single_step_execution.step_class_name
    # first check for syntax

    begin
      klass_location = @single_step_execution.code_file_location
      ap "reading #{klass_location}"
      klass_content = File.read(klass_location)
      ap "content:"
      ap klass_content
      check_for_class(klass_content)
      check_syntax(klass_location)
      ap "Syntax seems OK"
      require klass_location
      result = eval klass_content, $main_binding
      if result.is_a?(Class)
        raise ClassNotDefinedError.new("Mismatch! You provided #{klass_name} and the file defined #{result.name}") if result.name != klass_name
        return result
      end
    rescue ClassInvalidError => e1
      ap "ERROR loading #{klass_name}:"
      ap e1.errors
      ap "Output from loading #{klass_name}"
      ap e1.output
      raise e1
    rescue => e
      # Do something if the loading fails and class cannot be instantiated.
      ap "Could not load class #{klass_name} from file #{klass_location}"
      raise e
    end

    # Class not listed at the end of file, let's use the class name directly.

    begin
      require klass_location
      klass = class_from_string(klass_name)
      raise ClassNotDefinedError.new("Mismatch! You provided #{klass_name} and the file defined something else") if klass == nil
      return klass
    rescue => e
      ap e
      ap e.backtrace
      ap "Could not find class #{klass_name} in file #{klass_location}"
      raise e
    end
  end

  def check_for_class(code)
    klass = !!code.match(/class/)
    raise ClassNotDefinedError.new("That file does not define the class #{@single_step_execution.step_class_name}") unless klass
  end

  def check_syntax(klass_location)
    ap "Checking syntax of #{klass_location}"
    command = "ruby -c #{klass_location}"
    Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
      exit_status = wait_thr.value
      @success = exit_status.success?
      unless @success
        errors = stderr.read
        err = ClassInvalidError.new("Syntax error - #{@single_step_execution.step_class_name} could not be loaded")
        err.errors = errors
        err.output = stdout.read
        raise err
      end
    end

  end

  def serialized_execution
    serialization = ActiveModelSerializers::SerializableResource.new(@single_step_execution)
    serialization.to_json
  end
end