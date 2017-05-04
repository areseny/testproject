module Api
  module V1
    class PagesController < ApplicationController
      before_action :authenticate!, only: [:members_only]

      respond_to :json

      def anyone
        render json: {
                   data: {
                       message: "Welcome to INK api version 1, guest!"
                   }
               }, status: 200
      end

      def members_only
        data = {
            message: "Welcome to INK api version 1, #{current_entity.name}",
            :"#{current_entity.class.name.downcase}" => current_entity
        }

        render json: {
                   data: data
               }, status: 200
      end
    end
  end
end
