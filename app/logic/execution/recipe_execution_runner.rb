module Execution
  class RecipeExecutionRunner
    include EventConstants

    attr_accessor :step_array, :process_steps, :chain_file_location, :chain_id

    def initialize(process_step_hash:, chain_file_location:, chain_id:)
      @process_steps = process_step_hash
      @chain_file_location = chain_file_location
      @step_array = []
      @chain_id = chain_id
    end

    def run!
      return nil if @process_steps.empty?
      pipeline = build_pipeline
      pipeline.execute
      pipeline
    end

    def build_pipeline
      latest_in_chain = nil
      steps = @process_steps.sort.to_h.values
      steps.reverse.each do |process_step|
        next unless process_step
        step_class = process_step.step_class
        latest_in_chain = step_class.new(chain_file_location: chain_file_location, next_step: latest_in_chain, position: process_step.position)
        add_event_triggers(latest_in_chain)
        @step_array << latest_in_chain
      end

      @step_array.reverse!
      latest_in_chain
    end

    def add_event_triggers(step_object)
      step_object.class.include(EventConstants)
      step_object.class.include(DirectoryMethods)
      step_object.instance_variable_set(:@chain_id, @chain_id)
      step_object.instance_variable_set(:@recipe_id, ProcessChain.find(@chain_id).recipe_id)

      step_object.instance_variable_set(:@update_channel, process_chain_channel(@chain_id))
      step_object.instance_variable_set(:@process_step_started_event, process_step_started_event)
      step_object.instance_variable_set(:@process_step_finished_event, process_step_finished_event)

      step_object.define_singleton_method(:trigger_start_event!) do
        trigger_event(channels: @update_channel, event: @process_step_started_event, data: { chain_id: @chain_id, position: position, version: version, recipe_id: @recipe_id })
      end

      step_object.define_singleton_method(:trigger_completion_event!) do
        trigger_event(channels: @update_channel, event: @process_step_finished_event, data: { chain_id: @chain_id, position: position, successful: successful, notes: notes, execution_errors: errors, recipe_id: @recipe_id, output_file_manifest: assemble_manifest(working_directory) })
      end
    end
  end
end


  class NilClass
    def new
      nil
    end
  end

