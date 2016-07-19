require 'conversion_errors/conversion_errors'

module Conversion
  module Steps
    class Step
      include ConversionErrors
      include AuxiliaryHelpers

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
        # check file extension
        puts "(#{self.class.name}) Converting #{input_filename(input_file)}..."
        input_file
      end

      def raise_and_log_error(message)
        @errors << message
        raise message
      end

      protectedebook-convert input_file output_file

      def step_logic_file_location
        Rails.root.join("app", "logic", "conversion", "step_logic", class_name.to_underscore!)
      end

      def input_filename(input_file)
        return input_file if input_file.is_a? String
        return File.basename(File.absolute_path(input_file)) if input_file.is_a? File
        input_file.file.file
      end

      def input_file_extension(input_file)
        File.extname(input_filename(input_file))
      end
    end

  end
end