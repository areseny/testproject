require 'rails_helper'
require_relative '../version'

describe "Account sign out" do

  # URL: /api/auth/sign_out
  # Method: DELETE
  # Use this route to end the account's current session. This route will invalidate the account's authentication token.

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: account@example.com, auth_token: asdf" -X DELETE http://localhost:3000/api/auth/sign_out

  describe "DELETE sign out" do
    let!(:auth_headers) { account.create_new_auth_token }
    let!(:account)           { create(:account, password: "password", password_confirmation: "password") }

    context 'if account is signed in' do

      # {"access-token"=>"QQWgZPLpF8o9jNxdibLKPQ", "token-type"=>"Bearer", "client"=>"wWxg-wuhTmdgPu3hgoTrhA", "expiry"=>"1458632683", "uid"=>"person6@example.com"}

      before do
        perform_sign_out_request(auth_headers)
      end

      it 'responds with success' do
        expect(response.status).to eq(200)
      end

      it 'returns a successful message' do
        expect(body_as_json['success']).to eq true
      end
    end

    context 'if no account is supplied' do
      before do
        perform_sign_out_request(auth_headers.except('uid'))
      end

      it 'raises an error' do
        expect(response.status).to eq(404)
      end

      it 'provides a message' do
        expect_to_contain_string(body_as_json['errors'], /was not found or was not logged in/)
      end
    end

    context 'if account has already signed out' do
      before do
        perform_sign_out_request(auth_headers)
      end

      it 'raises an error' do
        perform_sign_out_request(auth_headers)

        expect(response.status).to eq(404)
      end

      it 'provides a message' do
        perform_sign_out_request(auth_headers)

        expect_to_contain_string(body_as_json['errors'], /was not found or was not logged in/)
      end
    end

    context 'if no token is supplied' do
      before do
        perform_sign_out_request(auth_headers.except('access-token'))
      end

      it 'raises an error' do
        expect(response.status).to eq(404)
      end

      it 'provides a message' do
        expect_to_contain_string(body_as_json['errors'], /was not found or was not logged in/)
      end
    end

    context 'if the token has expired' do
      before do
        expire_token(account, auth_headers['client'])
        perform_sign_out_request(auth_headers)
      end

      it 'raises an error' do
        expect(response.status).to eq(404)
      end

      it 'provides a message' do
        expect_to_contain_string(body_as_json['errors'], /was not found or was not logged in/)
      end
    end

  end

  def perform_sign_out_request(auth_headers)
    sign_out_request(version, auth_headers)
  end

end