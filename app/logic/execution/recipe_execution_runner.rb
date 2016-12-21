module Execution
  class RecipeExecutionRunner

    attr_accessor :step_array, :process_steps, :chain_file_location

    def initialize(process_step_hash:, chain_file_location:)
      @process_steps = process_step_hash
      @chain_file_location = chain_file_location
      @step_array = []
    end

    def run!
      return nil if @process_steps.empty?
      begin
        pipeline = build_pipeline
        pipeline.execute
      rescue => e
        ap e.message
        ap e.backtrace
      end
      pipeline
    end

    def build_pipeline
      latest_in_chain = nil
      steps = @process_steps.sort.to_h.values
      steps.reverse.each do |process_step|
        next unless process_step
        step_class = process_step.step_class
        latest_in_chain = step_class.new(chain_file_location: chain_file_location, next_step: latest_in_chain, position: process_step.position)
        @step_array << latest_in_chain
      end

      @step_array.reverse!
      latest_in_chain
    end

  end
end

class NilClass
  def new
    nil
  end
end