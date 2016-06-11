module Api
  module V1
    class PagesController < ApplicationController
      before_action :authenticate_api_user!, only: [:members_only]

      respond_to :json

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
                       message: "Welcome to api version 1, #{current_api_user.name}",
                       user: current_api_user
                   }
               }, status: 200
      end
    end
  end
end
