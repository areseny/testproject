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

      def is_text_file?(file)
        if file.respond_to?(:content_type)
          return text_mime_type?(file.content_type)
        end
        return_value = false
        fm= FileMagic.new(FileMagic::MAGIC_MIME)
        text_file = text_mime_type?(fm.file(filename))
        return_value = true if text_file
      rescue => e
        ap "Cannot read that file with FileMagick"
        ap e.message
        return nil
      ensure
        fm.close if fm.respond_to?(:close)
        return_value
      end

      def text_mime_type?(mime_type)
        # ap "checking mime type #{mime_type} to contain text -- #{!!(mime_type =~ /^text\//)}"
        !!(mime_type =~ /^text\//)
      end

      def file_path(file_name = nil)
        tmp_path = File.join(temp_directory, timestamp_slug)
        FileUtils::mkdir tmp_path unless File.exists?(tmp_path)
        return File.join(temp_directory, timestamp_slug, file_name) if file_name
        tmp_path
      end

      def extract_contents(input_file)
        print_step input_file.inspect
        if input_file.respond_to? :read
          input_file.read
        elsif input_file.is_a? String && File.exist?(input_file)
          File.read(input_file)
        else
          raise input_file
        end
      end

    end
  end
end