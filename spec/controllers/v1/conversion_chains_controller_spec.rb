require_relative 'version'

describe Api::V1::ConversionChainsController, type: :controller do
  include Devise::TestHelpers

  let!(:user)             { FactoryGirl.create(:user, password: "password", password_confirmation: "password") }
  let!(:demo_step)        { FactoryGirl.create(:step_class, name: "RotThirteen") }
  let!(:text_file)        { fixture_file_upload('files/plaintext.txt', 'text/plain') }
  let!(:recipe_step)      { FactoryGirl.create(:recipe_step, step_class: demo_step) }
  let!(:conversion_step)  { FactoryGirl.create(:conversion_step) }
  let!(:conversion_chain) { conversion_step.conversion_chain }

  let!(:params) {
    {
        id: conversion_chain.id
    }
  }

  before do
    recipe_step.update_attribute(:recipe_id, conversion_chain.recipe.id)
    conversion_chain.update_attribute(:user_id, user.id)
    conversion_chain.recipe.update_attribute(:user_id, user.id)
  end

  describe "GET download" do
    context 'when there is an output file' do
      before do
        FileUploader.enable_processing = true
        @uploader = FileUploader.new(conversion_chain, :input_file)

        File.open('spec/fixtures/files/plaintext.txt') do |f|
          @uploader.store!(f)
        end
      end


    end


  end

  describe "GET retry" do

    context 'if a valid token is supplied' do

      context 'if the chain belongs to that user' do

        context 'if a file is supplied' do
          before do
            FileUploader.enable_processing = true
            @uploader = FileUploader.new(conversion_chain, :input_file)

            File.open('spec/fixtures/files/plaintext.txt') do |f|
              @uploader.store!(f)
            end
          end

          context 'if the recipe has no steps' do
            before do
              recipe_step.destroy
            end

            it 'should try to execute the conversion chain' do
              request_with_auth(user.create_new_auth_token) do
                perform_retry_request(params)
              end

              expect(response.status).to eq 422
            end
          end

          context 'if the recipe has steps' do
            it 'should try to execute the conversion chain' do
              request_with_auth(user.create_new_auth_token) do
                perform_retry_request(params)
              end

              expect(response.status).to eq 200
              expect(assigns(:new_chain)).to_not eq conversion_chain
              expect(assigns(:new_chain).executed_at).to_not be_nil
            end
          end
        end
      end
    end

    context 'if no valid token is supplied' do

      it "should not assign anything" do
        request_with_auth do
          perform_retry_request(params)
        end

        expect(response.status).to eq 401
      end
    end

  end

  def perform_retry_request(data = {})
    retry_conversion(version, data)
  end

  def perform_download_request(data = {})
    download_file(version, data)
  end
end