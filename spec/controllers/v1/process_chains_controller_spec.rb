require 'rails_helper'
require_relative 'version'

describe Api::V1::ProcessChainsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let!(:user)             { create(:user, password: "password", password_confirmation: "password") }
  let!(:demo_step)        { "RotThirteenStep" }
  let!(:text_file)        { File.new('spec/fixtures/files/plaintext.txt', 'r') }
  let!(:recipe_step)      { create(:recipe_step, step_class_name: demo_step) }
  let!(:process_step)     { create(:process_step) }
  let!(:process_chain)    { process_step.process_chain }

  let!(:params) {
    {
        id: process_chain.id
    }
  }

  before do
    recipe_step.update_attribute(:recipe_id, process_chain.recipe.id)
    process_chain.update_attribute(:user_id, user.id)
    process_chain.recipe.update_attribute(:user_id, user.id)
  end

  describe "GET download" do
    context 'when there is an output file' do
      before do
        FileUploader.enable_processing = true
        @uploader = FileUploader.new(process_chain, :input_file)

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
            @uploader = FileUploader.new(process_chain, :input_file)

            File.open('spec/fixtures/files/plaintext.txt') do |f|
              @uploader.store!(f)
            end
          end

          context 'if the recipe has no steps' do
            before do
              recipe_step.destroy
            end

            it 'tries to execute the process chain' do
              request_with_auth(user.create_new_auth_token) do
                perform_retry_request(params)
              end

              expect(response.status).to eq 422
            end
          end

          context 'if the recipe has steps' do
            it 'tries to execute the process chain' do
              request_with_auth(user.create_new_auth_token) do
                perform_retry_request(params)
              end

              expect(response.status).to eq 200
              expect(assigns(:new_chain)).to_not eq process_chain
              expect(assigns(:new_chain).executed_at).to_not be_nil
            end
          end
        end
      end
    end

    context 'if no valid token is supplied' do

      it "does not assign anything" do
        request_with_auth do
          perform_retry_request(params)
        end

        expect(response.status).to eq 401
      end
    end

  end

  def perform_retry_request(data = {})
    retry_execution(version, data)
  end

  def perform_download_request(data = {})
    download_file(version, data)
  end
end