module Api
  module V1
    class ProcessStepsController < ApplicationController
      include DirectoryMethods

      before_action :authenticate_api_account!
      before_action :authorise_account!

      respond_to :json

      def download_output_file
        file_path = assemble_file_path(location: process_step.working_directory, relative_path: params[:relative_path])

        send_file(file_path,
                  :disposition => 'attachment',
                  :url_based_filename => true)
      end

      def download_output_zip
        zip_path = process_step.assemble_output_file_zip

        send_file(zip_path,
                  :disposition => 'attachment',
                  :url_based_filename => true)
      end

      private

      def process_step
        @process_step ||= ProcessStep.find(params[:id])
      end

      def authorise_account!
        if process_step.process_chain.account != current_api_account
          e = ExecutionErrors::NotAuthorisedError.new("That file is not accessible to you.")
          render_error(e)
        end
      end

    end
  end
end
