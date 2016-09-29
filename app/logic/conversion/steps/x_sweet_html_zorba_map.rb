require 'zip'
require 'auxiliary_helpers'
require 'conversion_errors/conversion_errors'

module Conversion
  module Steps
    class XSweetHtmlZorbaMap < DownloadAndExecuteXslWithSaxon

      def convert_file(incoming_html_file, options_hash = {})
        new_hash = options_hash.merge(remote_xsl_uri: remote_xsl_location)
        super(input_file, new_hash)
      end

      def remote_xsl_location
        "https://gitlab.coko.foundation/wendell/XSweet/blob/ink-api-publish/zorba-map.xsl"
      end

    end
  end
end