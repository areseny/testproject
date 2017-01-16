require 'pathname'

module DirectoryMethods

  def create_directory_if_needed(path)
    FileUtils.mkdir_p(path) unless File.directory?(path)
  end

  def assemble_manifest(directory_path)
    files = recursive_file_list(directory_path)
    files.inject([]) do |result, file_relative_path|
      file_info_hash = {}
      file_info_hash[:path] = file_relative_path
      absolute_file_path = File.join(directory_path, file_relative_path)
      file_info_hash[:size] = file_size_for_humans(absolute_file_path)
      result << file_info_hash
      result
    end

  end

  def recursive_file_list(directory_path)
    # ap "recursive_file_list of #{directory_path}"
    Dir.chdir(directory_path) do
      files = Dir["**/*"] # Dir["**/*.*"]
      files_only = []
      files.each do |file|
        full_path = File.join(directory_path, file)
        files_only << file if File.file?(full_path)
      end
      files_only
    end
  end

  def copy_fixture_file(relative_path, destination_directory)
    create_directory_if_needed(destination_directory)
    absolute_path = Rails.root.join('spec', 'fixtures', 'files', relative_path)
    raise "does not exist" unless File.exists?(absolute_path)
    FileUtils.cp(absolute_path, destination_directory)
  end

  def assemble_file_path(location:, relative_path:)
    raise "Please provide a relative file path" unless relative_path.present?
    file_path = File.join(location, relative_path)
    raise "Cannot find #{relative_path}" unless located_in?(location, file_path) && File.file?(Pathname.new(file_path))
    # raise "Cannot find #{relative_path}" unless File.exists?(file_path) && File.file?(file_path)
    file_path
  end

  def file_size_for_humans(path)
    file_size_in_bytes = File.size(path)
    if file_size_in_bytes > 299000
      "#{(file_size_in_bytes / 1000000.0).round(1)} MB"
    elsif file_size_in_bytes > 1000
      "#{(file_size_in_bytes / 1000.0).round(1)} kB"
    else
      "#{file_size_in_bytes} bytes"
    end
  end

  def located_in?(parent_directory, child)
    path = Pathname.new(child)
    path.fnmatch?(File.join(parent_directory,'**'))
  end

end