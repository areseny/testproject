require_relative 'version'

describe Api::V1::ConversionStepsController, type: :controller do
  include Devise::TestHelpers

  let!(:user)           { FactoryGirl.create(:user, password: "password", password_confirmation: "password") }

  describe "GET download" do

    let!(:conversion_step)        { FactoryGirl.create(:conversion_step) }

    let!(:download_params) {
      {id: conversion_step.id }
    }

    context 'if a valid token is supplied' do

      it 'should try to execute the conversion chain' do
        request_with_auth(user.create_new_auth_token) do
          perform_download_request(download_params)
        end

        expect(response.status).to eq 200
        expect(assigns(:conversion_step)).to_not be_nil
      end

    end

    context 'if no valid token is supplied' do

      it "should not assign anything" do
        request_with_auth do
          perform_download_request(download_params)
        end

        expect(response.status).to eq 401
      end
    end

  end

  def perform_download_request(data = {})
    download_file(version, data)
  end

end