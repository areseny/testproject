require 'constants'

location_string = Constants::FILE_LOCATION

raise "Please ensure file storage directory is specified in .env (Check env.sample if this file is missing)" unless location_string.present?

file_location = File.dirname(location_string)
FileUtils.mkdir_p(file_location) unless File.directory?(file_location)