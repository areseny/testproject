require 'rails_helper'
require_relative 'version'

describe Api::V1::Admin::AccountsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let!(:account)             { create(:account) }

  describe "GET index" do

    context 'if a valid token is supplied' do
      context 'and the account is an administrator' do
        before do
          create(:account_role, account: account, role: "admin")
        end

        specify do
          request_with_auth(account.create_new_auth_token) do
            perform_get_index_request({})
          end

          expect(response.status).to eq 200
          expect(body_as_json['accounts'].count).to eq Account.count
        end
      end

      context 'and the account is NOT an administrator' do
        before do
          create(:account_role, account: account, role: "pleb")
        end

        it 'rejects the request as unauthorised' do
          request_with_auth(account.create_new_auth_token) do
            perform_get_index_request({})
          end

          expect(response.status).to eq 401
        end
      end
    end

    context 'if no valid token is supplied' do
      it 'fails' do
        request_with_auth do
          perform_get_index_request({})
        end

        expect(response.status).to eq 401
      end
    end
  end

  def perform_get_index_request(data = {})
    get_index_request(version, data)
  end

  def perform_get_service_accounts_request(data = {})
    service_accounts_request(version, data)
  end
end