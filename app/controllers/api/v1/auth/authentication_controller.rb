module Api::V1::Auth
  class AuthenticationController < ApplicationController
    def sign_in
      account = Account.find_for_database_authentication(email: params[:email])
      if account.valid_password?(params[:password])
        render json: account_payload(account)
      else
        render json: {errors: ['Invalid credentials']}, status: :unauthorized
      end
    end

    private

    def account_payload(account)
      return nil unless account and account.id
      {
          auth_token: JsonWebToken.encode({account_id: account.id}),
          account: {id: account.id, email: account.email, admin: account.admin?}
      }
    end

    def service_payload(service)
      return nil unless service and service.id
      {
          auth_token: JsonWebToken.encode({service_id: service.id}),
          service: {id: service.id, email: service.email}
      }
    end
  end
end