require 'zip'
require 'auxiliary_helpers'
require 'conversion_errors/conversion_errors'

module Conversion
  module Steps

    class DocxToHtmlOttoville < ConversionStep
      include Conversion::Modules::SaxonXslMethods
      include Conversion::Modules::ZipMethods

      def initialize
        super
        setup_xsl(file_path: document_xml_path,
                  xslt_file_path: File.join(step_logic_file_location, "docx2html.xsl"))
      end

      def convert_file(input_file, options_hash = {})
        super

        unzip_docx(input_file)
        apply_xslt_transformation
      end
    end

  end
end