require 'zip'
require 'auxiliary_helpers'
require 'conversion_errors/conversion_errors'

module Conversion
  module Steps

    class DocxToHtmlXsl < ConversionStep
      include Conversion::Modules::SaxonXslMethods

      def initialize
        super
        setup_xsl(file_path: document_xml_path, xslt_file_path: File.join(step_logic_file_location, "docx-to-html-2-0.xsl"))
      end

      def convert_file(input_file, options_hash = {})
        super

        unzip_docx(input_file)

        apply_xsl_template
      end

      def unzip_docx(input_file)
        Zip::File.open(input_file) do |zip_file|
          zip_file.each do |f|
            path = File.join(unzip_directory, f.name)
            FileUtils.mkdir_p(File.dirname(path)) unless File.exists?(File.dirname(path))
            f.extract(path)
          end
        end
      rescue => e
        # puts e.message
        # puts e.backtrace
        raise ConversionErrors::ConversionError.new("Could not open docx file - please check to ensure it's a valid docx.")
      end

      def document_xml_path
        @document_xml_path ||= File.join(unzip_directory, "word", "document.xml")
      end

    end

  end
end