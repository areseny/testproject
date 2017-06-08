module Api::V1
  class ProcessStepsController < ApplicationController
    include DirectoryMethods

    before_action :authenticate!
    before_action :authorise_account!
    before_action :check_processing_finished!

    respond_to :json

    def download_output_file
      file_path = assemble_file_path(location: process_step.working_directory, relative_path: params[:relative_path])

      send_file(file_path,
                :disposition => 'attachment',
                :url_based_filename => true)
    end

    def download_output_zip
      unless process_step.finished?
        render_not_found_error("Not finished processing yet")
        return
      end
      zip_path = process_step.assemble_output_file_zip

      send_file(zip_path,
                :disposition => 'attachment',
                :url_based_filename => true)
    end

    def download_process_log
      ap "Downloading #{process_step.process_log_path}..."

      send_file(process_step.process_log_path,
                :disposition => 'attachment',
                :url_based_filename => true)
    end

    private

    def process_step
      @process_step ||= ProcessStep.find(params[:id])
    end

    def check_processing_finished!
      unless process_step.finished?
        render_not_found_error("Not finished processing yet")
      end
    end

    def authorise_account!
      if process_step.process_chain.account != current_entity.account
        e = ExecutionErrors::NotAuthorisedError.new("That file is not accessible to you.")
        render_error(e)
      end
    end

  end
end
