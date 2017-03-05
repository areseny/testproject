module Api
  module V1
    module Admin
      class AccountsController < ApplicationController
        before_action :authenticate_api_user!
        before_action :authorise_admin!

        respond_to :json

        def service_accounts
          render json: Service.all, status: 200
        end

        def users
          render json: User.all, status: 200
        end
      end
    end
  end
end
