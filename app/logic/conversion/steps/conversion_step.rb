module Conversion
  module Steps
    class ConversionStep < Step

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

      def extract_contents(input_file)
        # if File.exists?(input_file)
        #   contents = File.read(input_file)
        # else
        #   contents = input_file.read
        # end
        print_step input_file.inspect
        if input_file.respond_to? :read
          input_file.read
        elsif input_file.is_a? String && File.exist?(input_file)
          File.read(input_file)
        else
          input_file
        end
      end

    end
  end
end