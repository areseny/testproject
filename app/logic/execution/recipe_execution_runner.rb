require 'yaml'

module Execution
  class RecipeExecutionRunner
    include EventConstants
    include DirectoryMethods
    include ExecutionErrors

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
      raise EmptyChainError.new("Process steps are empty for chain #{@chain_id}") if @process_steps.empty?
      trigger_event(channels: execution_channel, event: process_chain_started_processing_event, data: { recipe_id: @process_chain.recipe_id, chain_id: chain_id})
      @process_chain.update_attribute(:executed_at, Time.zone.now)
      @process_chain.save_input_file_manifest!

      execute_process_steps
      trigger_event(channels: execution_channel, event: process_chain_done_processing_event, data: { recipe_id: @process_chain.recipe_id, chain_id: chain_id, output_file_manifest: @process_chain.output_file_manifest })
    rescue => e
      error = e
      trigger_event(channels: execution_channel, event: process_chain_error_event, data: { recipe_id: @process_chain.recipe_id, chain_id: chain_id, output_file_manifest: @process_chain.output_file_manifest, error: e.message})
    ensure
      @process_chain.map_results(@step_array)
      @process_chain.update_attribute(:finished_at, Time.now)
      if error
        raise error
      end
    end

    def execute_process_steps
      @file_manifest = @process_chain.input_file_manifest
      @process_steps.each do |process_step|
        behaviour_step = process_step.step_class.new(chain_file_location: chain_file_location,
                                                     position: process_step.position,
                                                     incoming_file_manifest: @file_manifest)

        @step_array << behaviour_step
        trigger_step_started_event(behaviour_step)
        begin
          create_directory_if_needed(behaviour_step.working_directory)
          behaviour_step.combined_parameters = process_step.execution_parameters
          behaviour_step.input_file_manifest = @file_manifest
          behaviour_step.execute(options: behaviour_step.combined_parameters)
        # rescue => e
        #   log(e.message)
        #   log(e.backtrace)
        ensure
          write_manifest!(process_step, behaviour_step.working_directory, @file_manifest)
          trigger_step_finished_event(behaviour_step, process_step)
        end
      end
    end

    def write_manifest!(process_step, directory, manifest_at_start = [])
      @file_manifest = semantically_tagged_manifest(directory, manifest_at_start)
      # manifest_path = File.join(directory, ".manifest")
      # File.open(manifest_path, 'w') { |file| file.write(manifest_content.to_yaml) }
      process_step.update_attribute(:output_file_list, @file_manifest)
    end

    def semantically_tagged_manifest(working_directory, manifest_at_start)
      file_manifest_at_end = assemble_manifest(directory: working_directory)
      file_manifest_at_end.each do |file_hash|
        start_file_hash = find_start_file(file_hash, manifest_at_start)
        if start_file_hash.nil?
          file_hash[:tag] = :new
        elsif file_hash[:checksum] == start_file_hash[:checksum]
          file_hash[:tag] = :identical
        else
          file_hash[:tag] = :modified
        end
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
                            process_log_location: process_step.process_log_relative_path,
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

