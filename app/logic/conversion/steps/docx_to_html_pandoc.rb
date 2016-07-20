require 'zip'
require 'auxiliary_helpers'
require 'conversion_errors/conversion_errors'

module Conversion
  module Steps

    class DocxToHtmlPandoc < ConversionStep

      # http://pandoc.org/getting-started.html

      def convert_file(input_file, options_hash = {})
        super
        output_filename = Rails.root.join(temp_directory, "pandoc_conversion_result_#{Time.now.to_i}_#{Random.rand(10000)}.html")
        # print_step "converting #{input_filename(input_file)} to #{output_filename}"
        do_conversion(input_filename(input_file), output_filename)
        print_step "#{File.exist?(output_filename)}"
        File.open(Rails.root.join(temp_directory, output_filename))
      end

      def temp_directory
        @temp_directory ||= Rails.root.join('tmp')
      end

      def file_path(file_name)
        File.join(temp_directory, timestamp_slug, file_name)
      end

      private

      def do_conversion(source_docx_file, destination_filename)
        print_step "running pandoc #{source_docx_file} -f docx -t html -s -o #{destination_filename}"
        system "pandoc #{source_docx_file} -f docx -t html -s -o #{destination_filename}"
      end
    end
  end
end