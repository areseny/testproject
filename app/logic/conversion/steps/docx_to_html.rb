require 'zip'
require 'auxiliary_helpers'
require 'conversion_errors/conversion_errors'

module Conversion
  module Steps

    class DocxToHtml < Step

      def convert_file(input_file, options_hash = {})
        super
        unzip_docx(input_file.file)
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

      # def apply_to_tmp_file(input_file)
      #   FileUtils::cp input_file.file, file_path(input_file.original_filename)
      #   @docx_temp_path = file_path(input_file.original_filename)
      # end

      # not my favourite thing, to introduce a Java dependency!
      # I'd like to use the C version directly via command line instead.
      # There's also a node.js port incoming
      # https://github.com/Saxonica/Saxon-CE/issues/1

      def apply_xslt_template
        # http://www.saxonica.com/html/documentation/using-xsl/commandline.html
        # java -jar Saxon-HE-9.7.0-4.jar -s:docx_to_html_test_file.docx -xsl:xslt_file_path -o:conversion_output.html

        system_call = "java -jar #{saxon_jar_path} -s:#{@docx_temp_path} -xsl:#{xslt_file_path} -o:#{output_file_path}"
        conversion_output = `#{system_call}`
        begin
          output_file = File.open(output_file_path)
          return output_file
        rescue => e
          # puts e.message
          # puts e.backtrace
          raise ConversionErrors::ConversionError.new(conversion_output)
        end
      end

      def temp_directory
        @temp_directory ||= Rails.root.join('tmp')
      end

      def unzip_directory
        @unzip_directory ||= File.join(temp_directory, timestamp_slug)
      end

      def timestamp_slug
        @timestamp ||= "#{Time.now.to_i}_#{random_alphanumeric_string}"
      end

      def file_path(file_name = nil)
        tmp_path = File.join(temp_directory, timestamp_slug)
        FileUtils::mkdir tmp_path unless File.exists?(tmp_path)
        return File.join(temp_directory, timestamp_slug, file_name) if file_name
        tmp_path
      end

      def saxon_jar_path
        Rails.root.join("lib", "Saxon-HE-9.7.0-4.jar")
      end

      def output_file_path
        @output_file_path ||= File.join(file_path, "conversion_output.html") #"#{unzip_directory}#{File::SEPARATOR}conversion_output.html"
      end

      def xslt_file_path
        @xslt_file_path ||= File.join(step_logic_file_location, "docx-to-html-2-0.xsl") #"#{step_logic_file_location}#{File::SEPARATOR}docx2html.xsl"
      end

      def document_xml_path
        @document_xml_path ||= File.join(unzip_directory, "word", "document.xml") #"#{unzip_directory}#{File::SEPARATOR}word#{File::SEPARATOR}document.xml"
      end

    end

  end
end