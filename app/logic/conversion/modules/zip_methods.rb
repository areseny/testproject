require 'zip'

module Conversion
  module Modules
    module ZipMethods
      def unzip_file(input_file)
        print_step "Unzipping archive..."
        Zip::File.open(input_file) do |archive|
          archive.each do |f|
            @archive_name = f.name unless @archive_name
            path = File.join(unzip_directory, f.name)
            FileUtils.mkdir_p(File.dirname(path)) unless File.exists?(File.dirname(path))
            f.extract(path)
          end
        end
      end

      def unzip_docx(input_file)
        Zip::File.open(input_file) do |zip_file|
          zip_file.each do |f|
            @docx_archive_name = f.name unless @docx_archive_name
            path = File.join(unzip_directory, f.name)
            FileUtils.mkdir_p(File.dirname(path)) unless File.exists?(File.dirname(path))
            f.extract(path)
          end
        end
      end

      def document_xml_path
        @document_xml_path ||= File.join(unzip_directory, "word", "document.xml")
      end
    end
  end
end