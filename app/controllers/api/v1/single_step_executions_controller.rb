module Api
  module V1
    class SingleStepExecutionsController < ApplicationController
      include ExecutionErrors
      include DirectoryMethods

      before_action :authenticate!
      before_action :authorise_account!, only: [:show, :download_input_file, :download_input_zip, :download_output_file, :download_output_zip]
      before_action :check_processing_finished!, only: [:download_output_file, :download_output_zip]

      respond_to :json

      def show
        render json: single_step_execution.as_json
      end

      def create
        new_single_step_execution[:execution_parameters] = params[:single_step_execution][:execution_parameters]
        new_single_step_execution.save!
        new_single_step_execution.start_execution!(input_files: input_file_param, code: params[:single_step_execution][:code])
        render json: new_single_step_execution
      rescue => e
        ap e.message
        ap e.backtrace
        render_error(e)
      end

      def index
        render json: current_entity.account.single_step_executions.as_json
      end

      def download_input_file
        ap "Downloading #{relative_path_param}..."
        file_path = assemble_file_path(location: single_step_execution.input_files_directory, relative_path: relative_path_param)

        send_file(file_path,
                  :disposition => 'attachment',
                  :url_based_filename => true)
      end

      def download_input_zip
        zip_path = single_step_execution.assemble_input_file_zip
        ap "Assembled #{zip_path}"

        send_file(zip_path,
                  :disposition => 'attachment',
                  :url_based_filename => true)
      end

      def download_output_file
        ap "Downloading #{relative_path_param} from #{single_step_execution.working_directory}..."
        file_path = assemble_file_path(location: single_step_execution.working_directory, relative_path: relative_path_param)
        send_file(file_path,
                  :disposition => 'attachment',
                  :url_based_filename => true)
      end

      def download_output_zip
        zip_path = single_step_execution.assemble_output_file_zip
        ap "Assembled #{zip_path}"

        send_file(zip_path,
                  :disposition => 'attachment',
                  :url_based_filename => true)
      end

      private

      def input_file_param
        params.require(:single_step_execution).require(:input_file_list)
      end

      def single_step_execution_params
        params.require(:single_step_execution).permit(:description, :step_class_name, :execution_parameters, :input_file_list)
      end

      def relative_path_param
        params.require(:relative_path)
      end

      def single_step_execution
        @single_step_execution ||= current_entity.account.single_step_executions.find(params[:id])
      end

      def single_step_executions
        @single_step_execution ||= current_entity.account.single_step_executions
      end

      def new_single_step_execution
        @single_step_execution ||= current_entity.account.single_step_executions.new(single_step_execution_params)
      end

      def authorise_account!
        if single_step_execution.account.id != current_entity.account.id && !current_entity.account.admin?
          e = ExecutionErrors::NotAuthorisedError.new("This is not accessible to you.")
          render_error(e)
        end
      rescue => e
        render_error(e)
      end

      def check_processing_finished!
        unless single_step_execution.finished?
          render_not_found_error("Not finished processing yet")
        end
      end
    end
  end
end