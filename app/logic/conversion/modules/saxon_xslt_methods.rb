module Conversion
  module Modules
    module SaxonXsltMethods
      attr_accessor :xslt_file_name, :xslt_file_path, :original_file_path

      def setup_xslt(name, file_path)
        @xslt_file_name = name
        @original_file_path = file_path
        set_xslt_file_path xslt_file_name
      end

      def set_xslt_file_path(name)
        @xslt_file_path ||= File.join(step_logic_file_location, name)
      end

      # not my favourite thing, to introduce a Java dependency!
      # I'd like to use the C version directly via command line instead.
      # There's also a node.js port incoming
      # https://github.com/Saxonica/Saxon-CE/issues/1

      def apply_xslt_template
        # http://www.saxonica.com/html/documentation/using-xsl/commandline.html
        # java -jar Saxon-HE-9.7.0-4.jar -s:docx_to_html_test_file.docx -xsl:xslt_file_path -o:conversion_output.html

        ap "Calling java -jar #{saxon_jar_path} -s:#{@original_file_path} -xsl:#{xslt_file_path} -o:#{output_file_path}"
        system_call = "java -jar #{saxon_jar_path} -s:#{@original_file_path} -xsl:#{xslt_file_path} -o:#{output_file_path}"
        conversion_output = `#{system_call}`
        begin
          output_file = File.open(output_file_path)
          return output_file
        rescue => e
          ap e.message
          ap e.backtrace
          raise ConversionErrors::ConversionError.new(conversion_output)
        end
      end

      def saxon_jar_path
        Rails.root.join("lib", "Saxon-HE-9.7.0-4.jar")
      end

    end
  end
end