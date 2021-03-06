module Api::V1::Admin
  class AccountsController < ApplicationController
    before_action :authenticate_account!
    before_action :authorise_admin!

    respond_to :json

    def service_accounts
      render json: Service.all, status: 200
    end

    def index
      render json: Account.all, status: 200
    end
  end
end
