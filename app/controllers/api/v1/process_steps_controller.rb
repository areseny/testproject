module Api
  module V1
    class ProcessStepsController < ApplicationController
      before_action :authenticate_api_user!
      before_action :authorise_user!

      respond_to :json

      def download_output_file
        file_path = assemble_file_path(process_step.working_directory)

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

      def authorise_user!
        if process_step.process_chain.user != current_api_user
          e = ExecutionErrors::NotAuthorisedError.new("That file is not accessible to you.")
          render_error(e)
        end
      end

    end
  end
end
