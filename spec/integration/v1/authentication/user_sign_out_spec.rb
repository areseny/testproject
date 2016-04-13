require 'rails_helper'
require_relative '../version'

describe "User sign out" do
  # include Devise::TestHelpers

  # URL: /api/auth/sign_out
  # Method: DELETE
  # Use this route to end the user's current session. This route will invalidate the user's authentication token.

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X DELETE http://localhost:3000/api/auth/sign_out

  describe "DELETE sign out" do
    let!(:auth_headers) { user.create_new_auth_token }
    let!(:user)           { FactoryGirl.create(:user, password: "password", password_confirmation: "password") }

    context 'if user is signed in' do

      # {"access-token"=>"QQWgZPLpF8o9jNxdibLKPQ", "token-type"=>"Bearer", "client"=>"wWxg-wuhTmdgPu3hgoTrhA", "expiry"=>"1458632683", "uid"=>"person6@example.com"}

      before do
        perform_sign_out_request(auth_headers)
      end

      it 'responds with success' do
        expect(response.status).to eq(200)
      end

      it 'should return a successful message' do
        expect(body_as_json['success']).to eq true
      end
    end

    context 'if no user is supplied' do
      before do
        perform_sign_out_request(auth_headers.except('uid'))
      end

      it 'should raise an error' do
        expect(response.status).to eq(404)
      end

      it 'should provide a message' do
        expect_to_contain_string(body_as_json['errors'], /was not found or was not logged in/)
      end
    end

    context 'if user has already signed out' do
      before do
        perform_sign_out_request(auth_headers)
      end

      it 'should raise an error' do
        perform_sign_out_request(auth_headers)

        expect(response.status).to eq(404)
      end

      it 'should provide a message' do
        perform_sign_out_request(auth_headers)

        expect_to_contain_string(body_as_json['errors'], /was not found or was not logged in/)
      end
    end

    context 'if no token is supplied' do
      before do
        perform_sign_out_request(auth_headers.except('access-token'))
      end

      it 'should raise an error' do
        expect(response.status).to eq(404)
      end

      it 'should provide a message' do
        expect_to_contain_string(body_as_json['errors'], /was not found or was not logged in/)
      end
    end

    context 'if the token has expired' do
      before do
        expire_token(user, auth_headers['client'])
        perform_sign_out_request(auth_headers)
      end

      it 'should raise an error' do
        expect(response.status).to eq(404)
      end

      it 'should provide a message' do
        expect_to_contain_string(body_as_json['errors'], /was not found or was not logged in/)
      end
    end

  end

  def perform_sign_out_request(auth_headers)
    sign_out_request(version, auth_headers)
  end

end