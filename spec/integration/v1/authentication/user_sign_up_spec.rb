require 'rails_helper'
require_relative '../version'

describe "User sign up" do

  # URL: /api/auth
  # Method: POST
  # Email registration. Requires email, password, and password_confirmation params

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1" -X POST -d '{"email":"user@example.com","password":"password","password_confirmation":"password"}' http://localhost:3000/api/auth


  describe "POST sign_up" do
    let(:email)              { generate(:email) }
    let(:password)           { "password" }

    context 'is successful' do
      it 'responds with success' do
        perform_sign_up_request(valid_params)

        expect(response.status).to eq(200)
      end

      it 'creates a new user' do
        perform_sign_up_request(valid_params)

        new_user = User.find(body_as_json['data']['id'])
        expect(new_user.email).to eq email
      end
    end

    context 'is missing a parameter' do
      it 'raises an error' do
        perform_sign_up_request(valid_params.except("password"))

        expect(response.status).to eq(422)
      end

      it 'does not sign up the user' do
        expect{
          perform_sign_up_request(valid_params.except("password"))
        }.to_not change{User.count}
      end

    end
  end

  def valid_params
    {
        "email" => email,
        "password" => password,
        "password_confirmation" => password
    }
  end

  def perform_sign_up_request(auth_headers)
    sign_up_request(version, auth_headers.to_json)
  end

end