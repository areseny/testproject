require 'rails_helper'
require_relative '../version'

describe "User sign in" do

  # URL: /api/auth/sign_in
  # Method: POST
  # Email authentication. Requires email and password as params.
  # This route will return a JSON representation of the User model on successful login along with the access-token and client in the header of the response.

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1" -X POST -d '{"email":"user@example.com","password":"password"}' http://localhost:3000/api/auth/sign_in

  describe "POST sign in" do
    let!(:password)       { "password" }
    let!(:user)           { FactoryGirl.create(:user, password: password, password_confirmation: password) }
    let!(:valid_params)   {
      {
          email: user.email,
          password: password
      }
    }

    context 'is successful' do

      it 'responds with success' do
        perform_sign_in_request(valid_params)

        expect(response.status).to eq(200)
      end

      it 'should return a valid token' do
        perform_sign_in_request(valid_params)

        expect(response.header['access-token']).to_not be_nil
        expect(response.header['client']).to_not be_nil
        expect(response.header['expiry']).to_not be_nil
      end
    end

    context 'is missing parameters' do
      it 'should raise an error' do
        perform_sign_in_request({})

        expect(response.status).to eq(401)
      end
    end

    context 'references a nonexistent user' do
      it 'should raise an error' do
        perform_sign_in_request(valid_params.merge(email: "nonsensical_rubbish@example.com"))

        expect(response.status).to eq(401)
      end
    end

    context 'is provided an incorrect password' do
      it 'should raise an error' do
        perform_sign_in_request(valid_params.merge(password: "nonsense"))

        expect(response.status).to eq(401)
      end
    end
  end

  def perform_sign_in_request(data)
    sign_in_request(version, data.to_json)
  end

end