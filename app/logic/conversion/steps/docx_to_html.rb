require 'zip'
require 'auxiliary_helpers'
require 'conversion_errors/conversion_errors'

module Conversion
  module Steps

    class DocxToHtml < Step

      def convert_file(input_file, options_hash = {})
        super
        unzip_docx(input_file)
        apply_xslt_template
      end

      def unzip_docx(input_file)
        Zip::File.open(input_file) do |zip_file|
          zip_file.each do |f|
            path = file_path(f.name)
            FileUtils.mkdir_p(File.dirname(path)) unless File.exists?(path)
            f.extract(path)
          end
        end
      end

      def apply_xslt_template
        # http://www.saxonica.com/html/documentation/using-xsl/commandline.html
        # java -jar Saxon-HE-9.7.0-4.jar -s:docx_to_html_test_file.docx -xsl:xslt_file_path -o:conversion_output.html

        conversion_output = system "java -jar #{Rails.root.join("lib")}#{File::SEPARATOR}Saxon-HE-9.7.0-4.jar -s:#{document_xml_path} -xsl:#{xslt_file_path} -o:#{output_file_path}"
        begin
          output_file = File.open(output_file_path)
          return output_file
        rescue
          raise ConversionErrors::ConversionError.new(conversion_output)
        end
      end

      def temp_directory
        @temp_directory ||= Rails.root.join('tmp')
      end

      def unzip_directory
        @unzip_directory ||= "#{temp_directory}#{File::SEPARATOR}#{timestamp_slug}"
      end

      def timestamp_slug
        @timestamp ||= "#{Time.now.to_i}_#{random_alphanumeric_string}"
      end

      def file_path(file_name)
        File.join(temp_directory, timestamp_slug, file_name)
      end

      def output_file_path
        @output_file_path ||= "#{unzip_directory}#{File::SEPARATOR}conversion_output.html"
      end

      def document_xml_path
        @document_xml_path ||= "#{unzip_directory}#{File::SEPARATOR}word#{File::SEPARATOR}document.xml"
      end

      def xslt_file_path
        "#{step_logic_file_location}#{File::SEPARATOR}docx2html.xsl"
      end

    end

  end
end