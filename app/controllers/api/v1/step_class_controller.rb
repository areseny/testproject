module Api
  module V1
    class StepClassController < ApplicationController
      before_action :authenticate!, only: [:index]

      respond_to :json

      def index
        @available_step_classes = StepClassCollector.step_class_hash
        render json: {available_step_classes: @available_step_classes}, status: 200
      rescue => e
        ap e.message
        ap e.backtrace
        render_error(e)
      end

      def index_by_gems
        @step_gems = StepClassCollector.step_gem_hash
        render json: {available_step_gems: @step_gems}, status: 200
      rescue => e
        ap e.message
        ap e.backtrace
        render_error(e)
      end

    end
  end
end
