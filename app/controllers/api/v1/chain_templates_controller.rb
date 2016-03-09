module Api
  module V1
    class ChainTemplatesController < ApplicationController
      before_action :authenticate_api_user!, only: [:index, :show, :create, :update, :destroy, :members_only]

      respond_to :json

      def index
        respond_with ChainTemplate.all
      end

      def show
        respond_with ChainTemplate.find(params[:id])
      end

      def create
        respond_with ChainTemplate.create(params[:product])
      end

      def update
        respond_with ChainTemplate.update(params[:id], params[:product])
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
        params.permit(:name)
      end

    end
  end
end
