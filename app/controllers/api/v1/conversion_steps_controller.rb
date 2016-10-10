module Api
  module V1
    class ConversionStepsController < ApplicationController
      before_action :authenticate_api_user!
      before_action :authorise_user!

      respond_to :json

      def download_file
        send_file(conversion_step.output_file.path,
                  :disposition => 'attachment',
                  :url_based_filename => true)
      end

      private

      # def conversion_step_params
      #   params.require(:conversion_step).permit(:name, :description, :active)
      # end
      #
      # def conversion_step_step_params
      #   params.permit(steps: [], steps_with_positions: [:name, :position])
      # end
      
      def conversion_step
        @conversion_step ||= ConversionStep.find(params[:id])
      end

      # def new_conversion_step
      #   @new_conversion_step ||= current_api_user.conversion_steps.new(conversion_step_params)
      # end
      #
      # def conversion_steps
      #   @conversion_steps ||= current_api_user.conversion_steps.active
      # end

      def authorise_user!
        if conversion_step.conversion_chain.user != current_api_user
          e = ExecutionErrors::NotAuthorisedError.new("That file is not accessible to you.")
          render_error(e)
        end
      end

    end
  end
end
