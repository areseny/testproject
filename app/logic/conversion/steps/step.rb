module Conversion
  module Steps
    class Step

      attr_accessor :next_step, :input_files, :output_files, :errors

      def initialize(next_step=nil)
        @next_step = next_step
        @errors = []
      end

      def execute(files, options_hash = {})
        @input_files = [files]
        modified_object = convert_file(files, options_hash)
      rescue => e
        raise_and_log_error(e.message)
      ensure
        @output_files = modified_object
        return modified_object if next_step.nil?
        next_step.execute(modified_object, options_hash)
      end

      # doesn't do anything! just returns the file as-is
      def convert_file(input_file, options_hash = {})
        raise_and_log_error("No file specified") unless input_file
        input_file
      end

      def raise_and_log_error(message)
        @errors << message
        raise message
      end

    end

  end
end