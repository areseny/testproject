require 'zip'
require 'auxiliary_helpers'
require 'conversion_errors/conversion_errors'

module Conversion
  module Steps

    class RotThirteen < Step

      def convert_file(input_file, options_hash = {})
        super
        contents = input_file.read
        result = contents.rot13
        filename = "rot13_result_#{Time.now.to_i}_#{Random.rand(10000)}.txt"
        File.write(Rails.root.join(temp_directory, filename), result)
        File.open(Rails.root.join(temp_directory, filename))
      end

      def temp_directory
        @temp_directory ||= Rails.root.join('tmp')
      end

      def file_path(file_name)
        File.join(temp_directory, timestamp_slug, file_name)
      end

    end

  end
end

# from https://gist.github.com/rwoeber/274126
class String
  def rot13
    split('').inject('') do |text, char|
      text << case char
        when 'a'..'m', 'A'..'M'
          char.ord + 13
        when 'n'..'z', 'N'..'Z'
          char.ord - 13
        else
          char.ord
      end
    end
  end
end