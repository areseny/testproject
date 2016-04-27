require 'nokogiri'

module Conversion
  module Steps

    class DocxToHtml < Step

      def convert_file(input_files, options_hash = {})
        super
        # check MIME type / file extension here too, perhaps?

        input_files
      end
    end

  end
end