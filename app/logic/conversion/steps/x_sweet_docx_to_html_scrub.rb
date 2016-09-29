require 'zip'
require 'auxiliary_helpers'
require 'conversion_errors/conversion_errors'

module Conversion
  module Steps
    class XSweetDocxToHtmlScrub < ConversionStep
      include Conversion::Modules::SaxonXslMethods
      include Conversion::Modules::ZipMethods

      def convert_file(incoming_html_file, options_hash = {})
        super
        unzip_transformation_archive

        setup_xsl(file_path: incoming_html_file,
                  xsl_file_path: xsl_file,
                  provided_saxon_jar_path: nil,
                  provided_working_directory: xsl_working_directory)
        apply_xslt_transformation
      end

      def unzip_transformation_archive
        print_step "Downloading xsl archive..."
        zip_archive = Tempfile.new("file")
        zip_archive.binmode # This might not be necessary depending on the zip file
        zip_archive.write(HTTParty.get(remote_zip_location).body)
        zip_archive.close

        unzip_file(zip_archive.path)
      end

      def xsl_working_directory
        File.join(unzip_directory, @archive_name)
      end

      def xsl_file
        File.join(xsl_working_directory, "scrub.xsl")
      end

      def remote_zip_location
        "https://gitlab.coko.foundation/wendell/XSweet/repository/archive.zip?ref=ink-api-publish"
      end

    end
  end
end