module Api
  module V1
    class ChainTemplatesController < ApplicationController
      before_action :authenticate_api_user!, only: [:index, :show, :create, :update, :destroy, :members_only]

      respond_to :json

      def index
        respond_with user.chain_templates
      end

      def show
        respond_with ChainTemplate.find(params[:id])
      end

      def create
        @chain_template = ChainTemplate.new(chain_template_params[:chain_template])
        @chain_template.user = current_api_user
        if @chain_template.save
          render json: @chain_template.to_json
        else
          render json: {errors: @chain_template.errors.messages}
        end
      end

      def update
        respond_with ChainTemplate.update(params[:id], params[:chain_template])
      end

      def destroy
        respond_with ChainTemplate.destroy(params[:id])
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
        params.permit(chain_template: [:name, :description])
      end

    end
  end
end
