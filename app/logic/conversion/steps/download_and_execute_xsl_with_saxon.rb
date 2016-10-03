module Conversion
  module Steps
    class DownloadAndExecuteXslWithSaxon < ConversionStep
      include Conversion::Modules::SaxonXslMethods
      include Conversion::Modules::ZipMethods

      attr_accessor :remote_xsl_uri
      require_parameters :remote_xsl_uri

      def convert_file(input_file, options_hash = {})
        super
        @remote_xsl_uri = options_hash[:remote_xsl_uri]

        download_file(remote_xsl_uri)

        apply_xslt_transformation(file_path: input_file,
                  xsl_file_path: xsl_file_path,
                  provided_saxon_jar_path: nil)
      end

      def download_file(file_uri)
        @downloaded_file_name = filename_from_uri(file_uri)
        print_step "Downloading #{file_uri}..."
        downloaded_file = File.new(File.join(temp_directory, @downloaded_file_name), "w")
        downloaded_file.write(HTTParty.get(file_uri).body)
        downloaded_file.close
      end

      def xsl_file_path
        File.join(temp_directory, @downloaded_file_name)
      end

      def filename_from_uri(uri)
        parsed_uri = URI.parse(uri)
        File.basename(parsed_uri.path)
      end
    end
  end
end