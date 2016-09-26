require 'zip'
require 'auxiliary_helpers'
require 'conversion_errors/conversion_errors'

module Conversion
  module Steps

    class DocxToHtmlOttoville < ConversionStep
      include Conversion::Modules::SaxonXsltMethods

      def initialize
        super
        setup_xslt "docx2html.xsl", document_xml_path
      end

      def convert_file(input_file, options_hash = {})
        super

        unzip_docx(input_file)
        apply_xslt_template
      end

      def unzip_docx(input_file)
        Zip::File.open(input_file) do |zip_file|
          zip_file.each do |f|
            path = File.join(unzip_directory, f.name)
            FileUtils.mkdir_p(File.dirname(path)) unless File.exists?(File.dirname(path))
            f.extract(path)
          end
        end
      end

      def output_file_path
        @output_file_path ||= File.join(unzip_directory, "ottoville_conversion_output.html") #"#{unzip_directory}#{File::SEPARATOR}conversion_output.html"
      end

      def document_xml_path
        @document_xml_path ||= File.join(unzip_directory, "word", "document.xml") #"#{unzip_directory}#{File::SEPARATOR}word#{File::SEPARATOR}document.xml"
      end
    end

  end
end