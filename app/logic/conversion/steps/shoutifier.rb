require 'zip'
require 'auxiliary_helpers'
require 'conversion_errors/conversion_errors'

module Conversion
  module Steps
    class Shoutifier < ConversionStep

      def convert_file(input_file, options_hash = {})
        super
        #is_text_file?
        contents = extract_contents(input_file)
        result = contents.shoutify
        filename = "shouty_result_#{Time.now.to_i}_#{Random.rand(10000)}#{input_file_extension(input_file)}"
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

class String
  def shoutify(format_html = true)
    inside_html_tag = false
    raise "The file is either empty or does not have text" if length == 0
    split('').inject('') do |text, char|
      text << case char
        when 'a'..'z', 'A'..'Z'
          if inside_html_tag && format_html
            char
          else
            char.upcase
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
