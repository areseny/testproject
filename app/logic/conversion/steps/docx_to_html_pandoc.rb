module Conversion
  module Steps

    class DocxToHtmlPandoc < ConversionStep

      # http://pandoc.org/getting-started.html

      def perform_step(input_file, options_hash = {})
        super
        output_filename = Rails.root.join(temp_directory, "pandoc_conversion_result_#{Time.now.to_i}_#{Random.rand(10000)}.html")
        print_step "converting #{input_filename(input_file)} to #{output_filename}"
        do_conversion(input_filename(input_file), output_filename)
        print_step "#{File.exist?(output_filename)}"
        if @success
          File.open(Rails.root.join(temp_directory, output_filename))
        end
      end

      private

      def do_conversion(source_docx_file, destination_filename)
        print_step "running pandoc #{source_docx_file} -f docx -t html -s -o #{destination_filename}"
        command = "pandoc #{source_docx_file} -f docx -t html -s -o #{destination_filename}"

        Open3.popen2e(command) do |stdin, stdout_err, wait_thr|
          exit_status = wait_thr.value
          @success = exit_status.success?
          unless @success
            err = stdout_err.read
            print_step "err: #{err}"
            @errors << err
          end
        end
      end
    end
  end
end