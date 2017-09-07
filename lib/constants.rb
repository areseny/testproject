class Constants

  # There is other code in steps that need these to be identical
  # so best leave them alone. :)

  ap "Loading file location from ENV[#{Rails.env.upcase}_FILE_LOCATION]"
  ap "File location set to #{ENV["#{Rails.env.upcase}_FILE_LOCATION"]}"
  FILE_LOCATION = ENV["#{Rails.env.upcase}_FILE_LOCATION"]
  INPUT_FILE_DIRECTORY_NAME = "input_files"
end