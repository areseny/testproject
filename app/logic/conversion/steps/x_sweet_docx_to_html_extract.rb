module Conversion
  module Steps
    class XSweetDocxToHtmlExtract < DownloadAndExecuteXslWithSaxonOnDocx

      def convert_file(input_file, options_hash = {})
        new_hash = options_hash.merge(remote_xsl_uri: remote_xsl_location)
        super(input_file, new_hash)
      end

      def remote_xsl_location
        "https://gitlab.coko.foundation/wendell/XSweet/blob/ink-api-publish/docx-html-extract.xsl"
      end

    end
  end
end