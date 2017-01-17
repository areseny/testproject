require 'constants'

class MigrateFilesToKitchenBench < ActiveRecord::Migration[5.0]
  include DirectoryMethods

  def change
    # check config location to ensure it has been set for this environment in ink_api.yml

    location_string = Constants::FILE_LOCATION
    raise "Please ensure file storage directory is specified in config/ink_api.yml (Check ink_api.yml.sample if this file is missing)" unless location_string.present?

    # create location in filesystem
    file_location = File.dirname(location_string)
    create_directory_if_needed(file_location)
    raise "Directory #{file_location} not created - check permissions" unless File.exists?(file_location)

    ProcessChain.all.each do |chain|
      puts "Moving files for chain #{chain.id}"
      # create chain slug directory in filesystem
      chain_directory = File.join(file_location, chain.slug)
      create_directory_if_needed(chain_directory)

      # create input_files
      chain_input_directory = File.join(file_location, chain.slug, Constants::INPUT_FILE_DIRECTORY_NAME)
      create_directory_if_needed(chain_input_directory)

      # copy input file to that directory
      puts "No input file" unless chain.input_file
      FileUtils.cp chain.carrierwave_input_file_path, File.join(chain_input_directory, chain.input_file_name)

      chain.process_steps.each do |step|
        puts "Moving files for step #{step.id}"
        # create position directory in filesystem under chain slug directory
        step_directory = File.join(file_location, chain.slug, step.position.to_s)
        create_directory_if_needed(step_directory)
        raise "Directory #{step_directory} not created - check permissions" unless File.exists?(step_directory)

        # create output_files in step slug directory

        # copy output file to that directory
        FileUtils.cp step.carrierwave_output_file_path, File.join(step.output_files_location, step.carrierwave_output_file_name)
      end
    end
  end

  class ProcessChain < ActiveRecord::Base
    has_many :process_steps, inverse_of: :process_chain, dependent: :destroy

    mount_uploader :input_file, FileUploader

    def carrierwave_input_file_path
      filename = input_file.path.split("/").last if input_file && input_file.path
      Rails.root.join("public", "uploads", "process_chain", "input_file", self.id.to_s, filename).to_s
    end

    def input_file_name
      carrierwave_input_file_path.split("/").last if input_file && input_file.path
    end

    def output_file_name
      carrierwave_input_file_path.split("/").last if output_file && output_file.path
    end

    def file_location
      File.join(Constants::FILE_LOCATION, slug)
    end
  end

  class ProcessStep < ActiveRecord::Base
    belongs_to :process_chain, inverse_of: :process_steps

    mount_uploader :output_file, FileUploader

    def carrierwave_output_file_path
      filename = output_file.path.split("/").last if output_file && output_file.path
      Rails.root.join("public", "uploads", "process_step", "output_file", self.id.to_s, filename).to_s
    end

    def carrierwave_output_file
      output_file
    end

    def carrierwave_output_file_name
      output_file.identifier unless output_file.identifier.nil?
      carrierwave_output_file_path.split("/").last if output_file && carrierwave_output_file_path
    end

    def file_location
      File.join(process_chain.file_location, position.to_s)
    end

    def output_files_location
      file_location
    end
  end

end
