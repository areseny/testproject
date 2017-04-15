module Api
  module V1
    class PagesController < ApplicationController
      before_action :authenticate_api_account!, only: [:members_only]

      respond_to :json

      def anyone
        render json: {
                   data: {
                       message: "Welcome to INK api version 1, guest!"
                   }
               }, status: 200
      end

      def members_only
        render json: {
                   data: {
                       message: "Welcome to INK api version 1, #{current_api_account.name}",
                       user: current_api_account
                   }
               }, status: 200
      end
    end
  end
end
