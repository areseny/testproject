module Execution
  class RecipeExecutionRunner
    include EventConstants
    include DirectoryMethods

    attr_accessor :step_array, :process_steps, :chain_file_location, :chain_id, :recipe_id

    def initialize(process_steps_in_order:, chain_file_location:, process_chain:)
      @step_array = []
      @process_steps = process_steps_in_order
      @chain_file_location = chain_file_location
      @process_chain = process_chain
      @recipe_id = process_chain.recipe_id
      @chain_id = @process_chain.id
    end

    def run!
      return nil if @process_steps.empty?
      trigger_event(channels: execution_channel, event: process_chain_started_processing_event, data: { recipe_id: @process_chain.recipe_id, chain_id: chain_id})
      @process_chain.update_attribute(:executed_at, Time.zone.now)
      @process_chain.save_input_file_manifest!

      execute_process_steps
      trigger_event(channels: execution_channel, event: process_chain_done_processing_event, data: { recipe_id: @process_chain.recipe_id, chain_id: chain_id, output_file_manifest: @process_chain.output_file_manifest })
    rescue => e
      trigger_event(channels: execution_channel, event: process_chain_error_event, data: { recipe_id: @process_chain.recipe_id, chain_id: chain_id, output_file_manifest: @process_chain.output_file_manifest, error: e.message})
    ensure
      @process_chain.map_results(@step_array)
      @process_chain.update_attribute(:finished_at, Time.now)
    end

    def execute_process_steps
      @process_steps.each do |process_step|
        behaviour_step = process_step.step_class.new(chain_file_location: chain_file_location, position: process_step.position)
        @step_array << behaviour_step
        trigger_step_started_event(behaviour_step)
        begin
          behaviour_step.execute
        # rescue => e
        #   log(e.message)
        #   log(e.backtrace)
        ensure
          trigger_step_finished_event(behaviour_step)
        end
      end
    end

    def trigger_step_started_event(behaviour_step)
      trigger_event(channels: execution_channel,
                    event: process_step_started_event,
                    data: { chain_id: @chain_id,
                            position: behaviour_step.position,
                            version: behaviour_step.version,
                            recipe_id: @recipe_id })
    end

    def trigger_step_finished_event(behaviour_step)
      trigger_event(channels: execution_channel,
                    event: process_step_finished_event,
                    data: { chain_id: @chain_id,
                            position: behaviour_step.position,
                            successful: behaviour_step.successful,
                            notes: behaviour_step.notes,
                            execution_errors: behaviour_step.errors,
                            recipe_id: @recipe_id,
                            output_file_manifest: assemble_manifest(behaviour_step.working_directory) })
    end
  end
end


class NilClass
  def new
    nil
  end
end

