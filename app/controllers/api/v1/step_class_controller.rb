module Api
  module V1
    class StepClassController < ApplicationController
      before_action :authenticate_api_account!, only: [:index]

      respond_to :json

      def index
        @step_classes = StepClassCollector.step_classes
        render json: {available_step_classes: @step_classes}, status: 200
      rescue => e
        ap e.message
        ap e.backtrace
        render_error(e)
      end

    end
  end
end
