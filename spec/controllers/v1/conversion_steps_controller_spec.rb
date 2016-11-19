require_relative 'version'

describe Api::V1::ConversionStepsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let!(:user)           { create(:user, password: "password", password_confirmation: "password") }

  describe "GET download" do

    let!(:conversion_step)        { create(:conversion_step) }

    let!(:download_params) {
      {id: conversion_step.id }
    }

    before do
      conversion_step.process_chain.update_attribute(:user_id, user.id)
      conversion_step.process_chain.recipe.update_attribute(:user_id, user.id)
    end

    context 'if a valid token is supplied' do

      context 'and the file belongs to that user' do
        it 'serves the file successfully' do
          request_with_auth(user.create_new_auth_token) do
            perform_download_request(download_params)
          end

          expect(response.status).to eq 200
          expect(assigns(:conversion_step)).to_not be_nil
        end
      end

      context 'and the file belongs to a different user' do
        before do
          other_user = create(:user)
          conversion_step.process_chain.update_attribute(:user_id, other_user.id)
        end

        it 'tries to download the file' do
          request_with_auth(user.create_new_auth_token) do
            perform_download_request(download_params)
          end

          expect(response.status).to eq 401
        end
      end

    end

    context 'if no valid token is supplied' do

      it "does not assign anything" do
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