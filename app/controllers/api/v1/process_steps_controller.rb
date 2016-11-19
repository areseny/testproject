module Api
  module V1
    class ProcessStepsController < ApplicationController
      before_action :authenticate_api_user!
      before_action :authorise_user!

      respond_to :json

      def download_file
        send_file(process_step.output_file.path,
                  :disposition => 'attachment',
                  :url_based_filename => true)
      end

      private

      # def process_step_params
      #   params.require(:process_step).permit(:name, :description, :active)
      # end
      #
      # def process_step_step_params
      #   params.permit(steps: [], steps_with_positions: [:name, :position])
      # end
      
      def process_step
        @process_step ||= ProcessStep.find(params[:id])
      end

      # def new_process_step
      #   @new_process_step ||= current_api_user.process_steps.new(process_step_params)
      # end
      #
      # def process_steps
      #   @process_steps ||= current_api_user.process_steps.active
      # end

      def authorise_user!
        if process_step.process_chain.user != current_api_user
          e = ExecutionErrors::NotAuthorisedError.new("That file is not accessible to you.")
          render_error(e)
        end
      end

    end
  end
end
