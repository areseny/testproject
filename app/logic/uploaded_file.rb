class UploadedFile

  attr_accessor :tempfile, :original_filename

  def initialize(input_files_directory:, relative_path:)
    @original_filename = relative_path
    @tempfile = File.join(input_files_directory, relative_path)
  end

end