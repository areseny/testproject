module Api
  module V1
    class ProcessChainsController < ApplicationController
      include ExecutionErrors
      include DirectoryMethods

      before_action :authenticate_api_user!, only: [:retry, :download_file]
      before_action :authorise_user!

      respond_to :json

      def retry
        @new_chain = process_chain.retry_execution!(current_api_user: current_api_user)
        render json: @new_chain, status: 200
      rescue => e
        puts e.message
        puts e.backtrace
        render_error(e)
      end

      def download_input_file
        file_path = assemble_file_path(process_chain.input_files_directory)

        send_file(file_path,
                  :disposition => 'attachment',
                  :url_based_filename => true)
      end

      def download_input_zip
        zip_path = process_chain.assemble_input_file_zip

        send_file(zip_path,
                  :disposition => 'attachment',
                  :url_based_filename => true)
      end

      def download_output_file
        file_path = assemble_file_path(process_chain.last_step.working_directory)

        send_file(file_path,
                  :disposition => 'attachment',
                  :url_based_filename => true)
      end

      def download_output_zip
        zip_path = process_chain.assemble_output_file_zip

        send_file(zip_path,
                  :disposition => 'attachment',
                  :url_based_filename => true)
      end

      private

      def process_chain_params
        params.require(:input_file)
      end

      def process_chain
        @process_chain ||= current_api_user.process_chains.find(params[:id])
      end

      def authorise_user!
        if process_chain.user != current_api_user
          e = ExecutionErrors::NotAuthorisedError.new("That recipe is not accessible to you.")
          render_error(e)
        end
      end
    end
  end
end
