module Conversion
  module Steps
    class Shoutifier < ConversionStep

      def perform_step(input_file, options_hash = {})
        super
        #is_text_file?
        contents = extract_contents(input_file)
        result = contents.shoutify
        filename = "shouty_result_#{Time.now.to_i}_#{Random.rand(10000)}#{input_file_extension(input_file)}"
        File.write(Rails.root.join(temp_directory, filename), result)
        File.open(Rails.root.join(temp_directory, filename))
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
