module Conversion
  module Steps
    class XSweetHtmlScrub < DownloadAndExecuteXslWithSaxon

      def convert_file(incoming_html_file, options_hash = {})
        new_hash = options_hash.merge(remote_xsl_uri: remote_xsl_location)
        super(input_file, new_hash)
      end

      def remote_xsl_location
        "https://gitlab.coko.foundation/wendell/XSweet/blob/ink-api-publish/scrub.xsl"
      end
    end
  end
end