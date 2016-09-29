require 'open3'
require 'conversion_errors/conversion_errors'

module Conversion
  module Modules
    module SaxonXslMethods
      attr_accessor :xslt_file_path, :original_file_path, :saxon_jar_path

      # not my favourite thing, to introduce a Java dependency!
      # I'd like to use the C version directly via command line instead.
      # There's also a node.js port incoming
      # https://github.com/Saxonica/Saxon-CE/issues/1

      def apply_xslt_transformation(file_path:, xsl_file_path:, provided_saxon_jar_path:)
        @original_file_path = file_path
        @xslt_file_path = xsl_file_path
        @saxon_jar_path = provided_saxon_jar_path || default_saxon_jar_path

        # http://www.saxonica.com/html/documentation/using-xsl/commandline.html
        # e.g.
        # java -jar Saxon-HE-9.7.0-4.jar -s:some_file.docx -xsl:xslt_file_path.xsl -o:conversion_output.html

        print_step "Applying xsl..."
        command = "java -jar #{saxon_jar_path} -s:#{@original_file_path} -xsl:#{xslt_file_path} -o:#{output_file_path}"
        print_step "Running command '#{command}'"

        Open3.popen2e(command) do |stdin, stdout_err, wait_thr|
          exit_status = wait_thr.value
          @success = exit_status.success?
          unless @success
            err = stdout_err.read
            print_step "err: #{err}"
            @errors << err
          end
        end

        # print_step "Does output file exist? #{File.exist?(output_file_path)}"
        if @success
          File.open(output_file_path)
        else
          # if not successful, halt the recipe at this step.
          raise ::ConversionErrors::ConversionError.new(@errors.inspect)
        end
      end

      def default_saxon_jar_path
        Rails.root.join("lib", "Saxon-HE-9.7.0-4.jar")
      end

      def output_file_path
        @output_file_path ||= File.join(temp_directory, "conversion_output.html")
      end

    end
  end
end