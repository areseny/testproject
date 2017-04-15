require 'rails_helper'
require_relative '../version'

describe "Account sign in" do

  # URL: /api/auth/sign_in
  # Method: POST
  # Email authentication. Requires email and password as params.
  # This route will return a JSON representation of the Account model on successful login along with the access-token and client in the header of the response.

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1" -X POST -d '{"email":"account@example.com","password":"password"}' http://localhost:3000/api/auth/sign_in

  describe "POST sign in" do
    let!(:password)       { "password" }
    let!(:account)           { create(:account, password: password, password_confirmation: password) }
    let!(:valid_params)   {
      {
          email: account.email,
          password: password
      }
    }

    context 'is successful' do

      it 'responds with success' do
        perform_sign_in_request(valid_params)

        expect(response.status).to eq(200)
      end

      it 'returns a valid token' do
        perform_sign_in_request(valid_params)

        expect(response.header['access-token']).to_not be_nil
        expect(response.header['client']).to_not be_nil
        expect(response.header['expiry']).to_not be_nil
      end
    end

    context 'is missing parameters' do
      it 'raises an error' do
        perform_sign_in_request({})

        expect(response.status).to eq(401)
        expect(body_as_json['errors']).to match(["Invalid login credentials. Please try again."])
      end
    end

    context 'references a nonexistent account' do
      it 'raises an error' do
        perform_sign_in_request(valid_params.merge(email: "nonsensical_rubbish@example.com"))

        expect(response.status).to eq(401)
        expect(body_as_json['errors']).to match(["Invalid login credentials. Please try again."])
      end
    end

    context 'is provided an incorrect password' do
      it 'raises an error' do
        perform_sign_in_request(valid_params.merge(password: "nonsense"))

        expect(response.status).to eq(401)
        expect(body_as_json['errors']).to match(["Invalid login credentials. Please try again."])
      end
    end
  end

  def perform_sign_in_request(data)
    sign_in_request(version, data.to_json)
  end

end