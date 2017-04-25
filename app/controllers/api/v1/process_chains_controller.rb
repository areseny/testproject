module Api
  module V1
    class ProcessChainsController < ApplicationController
      include ExecutionErrors
      include DirectoryMethods

      before_action :authenticate_api_account!, only: [:retry, :download_file]
      before_action :authorise_account!

      respond_to :json

      def retry
        @new_chain = process_chain.retry_execution!(current_api_account: current_api_account)
        render json: @new_chain, status: 200
      rescue => e
        puts e.message
        puts e.backtrace
        render_error(e)
      end

      def download_input_file
        ap "Downloading #{params[:relative_path]}..."
        file_path = assemble_file_path(location: process_chain.input_files_directory, relative_path: params[:relative_path])

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
        ap "Downloading #{params[:relative_path]} from #{process_chain.last_step.working_directory} (last step #{process_chain.last_step.id})..."
        unless process_chain.finished?
          render_not_found_error("Not finished processing yet")
          return
        end
        file_path = assemble_file_path(location: process_chain.last_step.working_directory, relative_path: params[:relative_path])
        send_file(file_path,
                  :disposition => 'attachment',
                  :url_based_filename => true)
      end

      def download_output_zip
        unless process_chain.finished?
          render_not_found_error("Not finished processing yet")
          return
        end
        zip_path = process_chain.assemble_output_file_zip

        send_file(zip_path,
                  :disposition => 'attachment',
                  :url_based_filename => true)
      end

      private

      def process_chain
        @process_chain ||= current_api_account.process_chains.find(params[:id])
      end

      def authorise_account!
        if process_chain.account != current_api_account
          e = ExecutionErrors::NotAuthorisedError.new("That recipe is not accessible to you.")
          render_error(e)
        end
      end
    end
  end
end
