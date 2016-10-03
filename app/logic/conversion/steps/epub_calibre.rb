module Conversion
  module Steps
    class EpubCalibre < ConversionStep

      # http://pandoc.org/getting-started.html

      def perform_step(input_file, options_hash = {})
        super
        output_file_path = Rails.root.join(temp_directory, "epub_calibre_#{Time.now.to_i}_#{Random.rand(10000)}.epub")
        print_step "converting #{input_filename(input_file)} to #{output_file_path}"
        print_step "path: #{absolute_file_path(input_file)}"
        do_conversion(absolute_file_path(input_file), output_file_path)
        if @success
          File.open(Rails.root.join(temp_directory, output_file_path))
        end
      end

      private

      def do_conversion(source_filename, destination_filename)
        # see readme for more info about usage
        # ebook-convert input_file output_file
        print_step "converting #{source_filename} to #{destination_filename}"
        command = "ebook-convert #{source_filename} #{destination_filename}"

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
