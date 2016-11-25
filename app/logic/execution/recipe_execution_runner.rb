module Execution
  class RecipeExecutionRunner

    attr_accessor :step_array, :process_steps

    def initialize(process_steps)
      @process_steps = process_steps
      @step_array = []
    end

    def run!(files:)
      return nil if @process_steps.empty?
      begin
        chain = build_chain
        chain.execute(files: files)
      rescue => e
        ap e.message
        ap e.backtrace
      end
      chain
    end

    def build_chain
      latest_in_chain = nil
      @process_steps.reverse.each do |process_step|
        next unless process_step
        step_class = process_step.step_class
        latest_in_chain = step_class.new(process_step: process_step, next_step: latest_in_chain)
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