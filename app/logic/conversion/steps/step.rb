require 'conversion_errors/conversion_errors'
require 'open3'

module Conversion
  module Steps
    class Step
      include ConversionErrors
      include AuxiliaryHelpers

      attr_accessor :next_step, :input_files, :output_files, :errors, :status_code

      def initialize(next_step=nil)
        @next_step = next_step
        @errors = []
      end

      def execute(files, options_hash = {})
        @input_files = [files]
        modified_object = convert_file(files, options_hash)
      rescue => e
        ap e.message
        ap e.backtrace
        raise_and_log_error(e.message)
        raise e
      ensure
        if @errors.any?
          return
        else
          @output_files = modified_object
          return modified_object if next_step.nil?
          next_step.execute(modified_object, options_hash)
        end
      end

      # doesn't do anything! just returns the file as-is
      def convert_file(input_file, options_hash = {})
        raise_and_log_error("No file specified") unless input_file
        # check file extension
        print_step "Converting #{input_filename(input_file)}..."
        input_file
      end

      def raise_and_log_error(message)
        @errors << message
        raise message
      end

      protected

      def step_logic_file_location
        Rails.root.join("app", "logic", "conversion", "step_logic", class_name.to_underscore!)
      end

      def input_filename(input_file)
        return input_file if input_file.is_a? String
        return input_file.original_filename if input_file.is_a? Rack::Test::UploadedFile
        return File.basename(input_file) if input_file.is_a? File
        input_file.file.file
      end

      def input_file_extension(input_file)
        File.extname(input_filename(input_file))
      end

      def absolute_file_path(input_file)
        return File.absolute_path(input_file) if input_file.is_a? File
        return input_file.path if input_file.is_a? Rack::Test::UploadedFile
        return input_file.file.file if input_file.respond_to?(:file)
        input_file
      end

      def print_step(message)
        ap "[#{self.class.name.demodulize}] - #{message}"
      end
    end

  end
end