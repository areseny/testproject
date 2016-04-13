module Conversion
  class RecipeExecutionRunner

    attr_accessor :steps, :step_array

    def initialize(steps)
      @steps = steps
      @step_array = []
    end

    def run!(files)
      return nil if steps.empty?
      begin
        chain = build_chain
        chain.execute(files)
      rescue => e
        puts e.message
      end
      chain
    end

    def build_chain
      latest_in_chain = nil
      steps.reverse.each do |step|
        next unless step
        latest_in_chain = step.new(latest_in_chain)
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