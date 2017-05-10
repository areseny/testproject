require 'rails_helper'
require_relative 'version'

describe Api::V1::Auth::AuthenticationController, type: :controller do

  let!(:account)             { create(:account) }

  describe "POST auth_account" do
    context 'with valid credentials' do
      it 'is successful' do
        perform_sign_in_request({email: account.email, password: account.password})

        expect(response.status).to eq 200
        expect(body_as_json['data']['account']).to eq({"id" => account.id, "email" => account.email, "admin" => account.admin?, "uid" => account.uid, "name" => account.name})
      end
    end

    context 'with invalid credentials' do
      it 'fails' do
        perform_sign_in_request({email: account.email, password: "RUBBISH LOL"})

        expect(response.status).to eq 401
      end
    end
  end

  def perform_sign_in_request(data = {})
    post_sign_in_request(version, data)
  end
end