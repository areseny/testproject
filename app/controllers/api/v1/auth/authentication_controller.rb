module Api::V1::Auth
  class AuthenticationController < ApplicationController
    def sign_in
      @account = Account.find_for_database_authentication(email: params[:email])
      if @account.valid_password?(params[:password])
        set_response_headers
        render json: {data: account_payload}
      else
        render json: {errors: ['Invalid credentials']}, status: :unauthorized
      end
    end

    private

    def set_response_headers
      response.headers["Access-Token"] = @account.generate_token
      response.headers["Token-Type"] = "Bearer"
      response.headers["Client"] = SecureRandom.urlsafe_base64(nil, false)
      response.headers["uid"] = @account.uid
    end

    def account_payload
      return nil unless @account and @account.id
      {
          account: {id: @account.id, email: @account.email, admin: @account.admin?, uid: @account.uid, name: @account.name}
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