require 'yaml'

module Execution
  class RecipeExecutionRunner
    include EventConstants
    include DirectoryMethods
    include ExecutionErrors

    attr_accessor :step_array, :process_steps, :base_file_location, :chain_id, :recipe_id, :cumulative_file_manifest

    def initialize(process_steps_in_order:, base_file_location:, process_chain:)
      @step_array = []
      @process_steps = process_steps_in_order
      @base_file_location = base_file_location
      @process_chain = process_chain
      @recipe_id = process_chain.recipe_id
      @chain_id = @process_chain.id
    end

    def run!
      raise EmptyChainError.new("Process steps are empty for chain #{@chain_id}") if @process_steps.empty?
      trigger_event(channels: execution_channel, event: process_chain_started_processing_event, data: { recipe_id: @process_chain.recipe_id, chain_id: chain_id})
      @process_chain.update_attribute(:executed_at, Time.zone.now)

      execute_process_steps
      trigger_event(channels: execution_channel, event: process_chain_done_processing_event, data: { recipe_id: @process_chain.recipe_id, chain_id: chain_id, output_file_manifest: @process_chain.output_file_manifest })
    rescue => e
      error = e
      trigger_event(channels: execution_channel, event: process_chain_error_event, data: { recipe_id: @process_chain.recipe_id, chain_id: chain_id, output_file_manifest: @process_chain.output_file_manifest, error: e.message})
    ensure
      @process_chain.update_attribute(:finished_at, Time.now)
      if error
        raise error
      end
    end

    def execute_process_steps
      @cumulative_file_manifest = {}
      @process_steps.each do |process_step|
        behaviour_step = process_step.step_class.new(base_file_location: base_file_location,
                                                     position: process_step.position)
        @step_array << behaviour_step
        trigger_step_started_event(behaviour_step)
        begin
          behaviour_step.combined_parameters = process_step.execution_parameters
          add_to_cumulative_manifest(behaviour_step)
          behaviour_step.cumulative_file_manifest = cumulative_file_manifest
          behaviour_step.execute
        # rescue => e
        #   log(e.message)
        #   log(e.backtrace)
        ensure
          process_step.map_results(behaviour_step: behaviour_step)
          add_to_cumulative_manifest(behaviour_step)
          trigger_step_finished_event(behaviour_step, process_step)
        end
      end
    end

    def add_to_cumulative_manifest(behaviour_step)
      if cumulative_file_manifest[:input].nil?
        cumulative_file_manifest[:input] = behaviour_step.input_file_manifest
      end
      if behaviour_step.output_file_manifest.present?
        cumulative_file_manifest[behaviour_step.position] = behaviour_step.output_file_manifest
      end
    end

    def find_start_file(current_file_hash, manifest_at_start)
      manifest_at_start.collect{|f| return f if f[:path] == current_file_hash[:path]}.first
    end

    def trigger_step_started_event(behaviour_step)
      trigger_event(channels: execution_channel,
                    event: process_step_started_event,
                    data: { chain_id: @chain_id,
                            position: behaviour_step.position,
                            version: behaviour_step.version,
                            recipe_id: @recipe_id })
    end

    def trigger_step_finished_event(behaviour_step, process_step)
      trigger_event(channels: execution_channel,
                    event: process_step_finished_event,
                    data: { chain_id: @chain_id,
                            position: behaviour_step.position,
                            successful: behaviour_step.successful,
                            notes: behaviour_step.notes,
                            execution_errors: behaviour_step.errors,
                            process_log_location: process_step.process_log_file_name,
                            recipe_id: @recipe_id,
                            output_file_manifest: process_step.output_file_manifest })
    end
  end
end


class NilClass
  def new
    nil
  end
end

