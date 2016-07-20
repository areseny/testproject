require 'zip'
require 'auxiliary_helpers'
require 'conversion_errors/conversion_errors'

module Conversion
  module Steps

    class RotThirteen < ConversionStep

      def convert_file(input_file, options_hash = {})
        super
        contents = extract_contents(input_file)
        begin
          result = contents.rot13
        rescue => e
          puts e.message.inspect
          puts e.backtrace
        end
        puts "converting!!!"
        filename = "rot13_result_#{Time.now.to_i}_#{Random.rand(10000)}#{input_file_extension(input_file)}"
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
  def rot13(format_html = true)
    inside_html_tag = false
    split('').inject('') do |text, char|
      text << case char
        when 'a'..'m', 'A'..'M'
          if inside_html_tag && format_html
            char.ord
          else
            char.ord + 13
          end
        when 'n'..'z', 'N'..'Z'
          if inside_html_tag && format_html
            char.ord
          else
            char.ord - 13
          end
        when '>'
          inside_html_tag = false
          char.ord
        when '<'
          inside_html_tag = true
          char.ord
        else
          char.ord
      end
    end
  end
end