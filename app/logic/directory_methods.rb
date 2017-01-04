module DirectoryMethods

  def create_directory_if_needed(path)
    FileUtils.mkdir_p(path) unless File.directory?(path)
  end

  def assemble_manifest(directory_path)
    files = recursive_file_list(directory_path)
    # [5, 6, 7, 8].inject (0) { |result_memo, object| result_memo + object }
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
      Dir["**/*.*"]
    end
  end

  def copy_fixture_file(relative_path, destination_directory)
    create_directory_if_needed(destination_directory)
    absolute_path = Rails.root.join('spec', 'fixtures', 'files', relative_path)
    raise "does not exist" unless File.exists?(absolute_path)
    FileUtils.cp(absolute_path, destination_directory)
  end

  def assemble_file_path(location)
    raise "Please provide a relative file path" unless params[:relative_path].present?
    file_path = File.join(location, params[:relative_path])
    raise "Cannot find #{params[:relative_path]}" unless File.exists?(file_path) && File.file?(file_path)
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

  # def experimental_file_list(directory_path)
  #   i=0
  #   curr_file = nil
  #
  #   Dir.chdir(directory_path) do
  #     Dir.glob("**/*") do |f|
  #       file = File.stat(f)
  #       next unless file.file?
  #       i += 1
  #       curr_file = [f, file] if curr_file.nil? or curr_file[1].ctime > file.ctime
  #     end
  #
  #     puts "#{curr_file[0]} #{curr_file[1].ctime.to_s}"
  #     puts "total files #{i}"
  #   end
  # end

end