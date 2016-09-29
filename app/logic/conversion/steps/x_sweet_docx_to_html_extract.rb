require 'zip'
require 'auxiliary_helpers'
require 'conversion_errors/conversion_errors'

module Conversion
  module Steps
    class XSweetDocxToHtmlExtract < ConversionStep
      include Conversion::Modules::SaxonXslMethods
      include Conversion::Modules::ZipMethods

      def convert_file(input_file, options_hash = {})
        super
        unzip_docx(input_file)
        download_file(remote_xsl_location)

        apply_xslt_transformation(file_path: document_xml_path,
                  xsl_file_path: xsl_file,
                  provided_saxon_jar_path: nil)
      end

      def download_file(file_uri)
        @downloaded_file_name = "docx-html-extract.xsl"
        print_step "Downloading #{file_uri}..."
        downloaded_file = File.new(File.join(temp_directory, @downloaded_file_name), "w")
        downloaded_file.write(HTTParty.get(file_uri).body)
        downloaded_file.close
      end

      def xsl_file
        File.join(temp_directory, @downloaded_file_name)
      end

      def remote_xsl_location
        "https://gitlab.coko.foundation/wendell/XSweet/blob/ink-api-publish/docx-html-extract.xsl"
      end

    end
  end
end