require 'yaml'

module Execution
  class StandaloneExecutionRunner
    include EventConstants
    include DirectoryMethods
    include ExecutionErrors

    attr_accessor :working_directory, :klass, :standalone_execution

    def initialize(klass:, single_step_execution:)
      # load behaviour class
      @klass = klass
      @standalone_execution = single_step_execution
      @working_directory = @standalone_execution.working_directory
    end

    def run!
      trigger_event(channels: execution_channel, event: standalone_execution_started_event(@standalone_execution.account_id), data: { single_step_execution_id: @standalone_execution.id})
      @standalone_execution.update_attribute(:executed_at, Time.zone.now)

      execute_standalone_step

      trigger_event(channels: execution_channel, event: standalone_execution_finished_event(@standalone_execution.account_id), data: { output_file_manifest: @standalone_execution.output_file_manifest })
    rescue => e
      error = e
      trigger_event(channels: execution_channel, event: standalone_execution_error_event, data: { output_file_manifest: @standalone_execution.output_file_manifest, error: e.message})
    ensure
      @standalone_execution.update_attribute(:finished_at, Time.now)
      if error
        raise error
      end
    end

    def execute_standalone_step
      behaviour_step = klass.new(base_file_location: working_directory, position: 1)
      trigger_step_started_event(behaviour_step)
      begin
        behaviour_step.combined_parameters = @standalone_execution.execution_parameters
        behaviour_step.execute
      # rescue => e
      #   log(e.message)
      #   log(e.backtrace)
      ensure
        standalone_execution.map_results(behaviour_step: behaviour_step)
        trigger_standalone_execution_finished_event(behaviour_step, standalone_execution)
      end
    end

    def trigger_step_started_event(behaviour_step)
      trigger_event(channels: standalone_execution_channel(@standalone_execution.account_id),
                    event: standalone_execution_started_event(@standalone_execution.account_id),
                    data: { position: behaviour_step.position })
    end

    def trigger_standalone_execution_finished_event(behaviour_step, standalone_step)
      trigger_event(channels: standalone_execution_channel(@standalone_execution.account_id),
                    event: standalone_execution_finished_event(@standalone_execution.account_id),
                    data: { position: behaviour_step.position,
                            successful: behaviour_step.successful,
                            notes: behaviour_step.notes,
                            execution_errors: behaviour_step.errors,
                            process_log_location: standalone_step.process_log_file_name,
                            output_file_manifest: standalone_step.output_file_manifest })
    end
  end
end


class NilClass
  def new
    nil
  end
end

