module DownloadableMethods
  def open_input_files
    recursive_file_list(input_files_directory).inject([]) do |list, file|
      list << UploadedFile.new(input_files_directory: input_files_directory, relative_path: file)
      list
    end
  end

  def save_input_file_manifest!
    self.input_file_list = assemble_manifest(directory: input_files_directory)
    save!
  end

  def input_file_manifest
    unless input_file_list.present?
      save_input_file_manifest!
    end
    input_file_list
  end

  def assemble_input_file_zip
    Dir.chdir(input_files_directory) do
      unless File.exists?(zip_path)
        `zip -r "#{zip_path}" *`
      end
    end
  rescue => e
    ap e.message
    ap e.backtrace
  end

  def output_file_manifest
    if respond_to?(:last_step)
      return last_step.output_file_manifest
    end

    if !finished?
      []
    elsif output_file_list.present?
      output_file_list
    elsif File.exists?(working_directory)
      assemble_manifest(directory: working_directory)
    else
      # @TODO flag an error to admin!
      ap "Cannot find file location for #{self.class.name} id '#{self.id}'"
      ap "Looking in #{working_directory}"
      []
    end
  end

  def assemble_output_file_zip
    if respond_to?(:last_step)
      return last_step.assemble_output_file_zip
    end

    zip_path = "/tmp/step_#{id}_output.zip"
    Dir.chdir(working_directory) do
      unless File.exists?(zip_path)
        `zip -r "#{zip_path}" *`
      end
    end
    zip_path
  end
end