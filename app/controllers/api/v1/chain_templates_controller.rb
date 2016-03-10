module Api
  module V1
    class ChainTemplatesController < ApplicationController
      before_action :authenticate_api_user!, only: [:index, :show, :create, :update, :destroy, :members_only]

      respond_to :json

      def create
        new_chain_template.generate_step_templates(step_template_params[:steps])
        new_chain_template.save!
        render json: new_chain_template
      rescue => e
        # puts e.message
        render json: {errors: [e.message]}, status: 422
      end

      def index
        render json: chain_templates.to_json
      end

      def show
        render json: chain_template, include: ['step_templates']
      rescue => e
        render json: {"errors": [e.message]}, status: 404
      end

      def update
        chain_template.update!(chain_template_params)
        render json: chain_template
      rescue ActiveRecord::RecordNotFound => e
        render json: {"errors": [e.message]}, status: 404
      rescue => e
        render json: {"errors": [e.message]}, status: 422
      end

      def destroy
        chain_template.destroy
        render json: chain_template
      rescue => e
        render json: {"errors": [e.message]}, status: 404
      end

      # test methods

      def anyone
        render json: {
                   data: {
                       message: "Welcome to api version 1, guest!"
                   }
               }, status: 200
      end

      def members_only
        render json: {
                   data: {
                       message: "Welcome to api version 1, #{current_user.name}",
                       user: current_user
                   }
               }, status: 200
      end

      private

      def chain_template_params
        params.require(:chain_template).permit(:name, :description, :active)
      end

      def step_template_params
        params.permit(steps: [:name, :position])
      end

      def chain_template
        @chain_template ||= current_api_user.chain_templates.find(params[:id])
      end

      def new_chain_template
        @new_chain_template ||= current_api_user.chain_templates.new(chain_template_params)
      end

      def chain_templates
        @chain_templates ||= current_api_user.chain_templates.active
      end

    end
  end
end
