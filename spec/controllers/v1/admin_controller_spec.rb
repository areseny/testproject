require 'rails_helper'
require_relative 'version'

describe Api::V1::Admin::AccountsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let!(:user)             { create(:user) }

  describe "GET users" do

    context 'if a valid token is supplied' do
      context 'and the user is an administrator' do
        before do
          create(:user_role, user: user, role: "admin")
        end

        it 'serves the file successfully' do
          request_with_auth(user.create_new_auth_token) do
            perform_get_users_request({})
          end

          expect(response.status).to eq 200
          expect(body_as_json['users'].count).to eq User.count
        end
      end

      context 'and the user is NOT an administrator' do
        before do
          create(:user_role, user: user, role: "pleb")
        end

        it 'rejects the request as unauthorised' do
          request_with_auth(user.create_new_auth_token) do
            perform_get_users_request({})
          end

          expect(response.status).to eq 401
        end
      end
    end

    context 'if no valid token is supplied' do
      it 'fails' do
        request_with_auth do
          perform_get_users_request({})
        end

        expect(response.status).to eq 401
      end
    end
  end

  def perform_get_users_request(data = {})
    get_users_request(version, data)
  end

  def perform_get_service_accounts_request(data = {})
    service_accounts_request(version, data)
  end
end