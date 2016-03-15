require 'nokogiri'

module Conversion
  module Steps

    class XmlToHtml < Step

      def convert_file(input_file, options_hash = {})
        super
        # check MIME type / file extension here too, perhaps?

        raise "No XSLT template file specified" unless options_hash[:xslt_template]

        document = Nokogiri::XML(File.read(input_file))
        template = Nokogiri::XSLT(File.read(options_hash[:xslt_template]))

        template.transform(document)
      end
    end

  end
end