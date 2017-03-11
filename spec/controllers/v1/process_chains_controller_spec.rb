require 'rails_helper'
require_relative 'version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe Api::V1::ProcessChainsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let!(:user)             { create(:user, password: "password", password_confirmation: "password") }
  let!(:demo_step)        { rot_thirteen_step_class.to_s }
  let!(:text_file)        { File.new('spec/fixtures/files/plaintext.txt', 'r') }
  let!(:recipe)           { create(:recipe) }
  let!(:recipe_step)      { recipe.recipe_steps.first }
  let!(:process_step)     { create(:process_step) }
  let!(:process_chain)    { process_step.process_chain }

  let!(:params) {
    {
        id: process_chain.id
    }
  }

  before do
    process_chain.update_attribute(:recipe_id, recipe.id)
    process_chain.update_attribute(:user_id, user.id)
    process_chain.recipe.update_attribute(:user_id, user.id)
    process_chain.initialize_directories
    copy_fixture_file("plaintext.txt", process_chain.input_files_directory)
  end

  describe "GET download_input_zip" do
    let!(:download_params) {
      {
          id: process_chain.id
      }
    }

    context 'if a valid token is supplied' do
      context 'and the chain belongs to that user' do
        it 'serves the file successfully' do
          request_with_auth(user.create_new_auth_token) do
            perform_download_input_zip_request(download_params)
          end

          expect(response.status).to eq 200
          expect(response.stream.to_path).to eq "/tmp/chain_#{process_chain.id}_input.zip"
        end
      end
    end
  end

  describe "GET download_output_zip" do
    let!(:download_params) {
      {
          id: process_chain.id
      }
    }

    before do
      create_directory_if_needed(process_step.working_directory)
      copy_fixture_file('some_text.txt', process_step.working_directory)
      process_step.process_chain.update_attribute(:user_id, user.id)
      process_step.process_chain.recipe.update_attribute(:user_id, user.id)
    end

    context 'if a valid token is supplied' do
      context 'and the chain belongs to that user' do
        it 'serves the file successfully' do
          request_with_auth(user.create_new_auth_token) do
            perform_download_output_zip_request(download_params)
          end

          expect(response.status).to eq 200
          expect(response.stream.to_path).to eq "/tmp/step_#{process_chain.last_step.id}_output.zip"
        end
      end
    end
  end

  describe "GET download_output_file" do

    before do
      create_directory_if_needed(process_step.send(:working_directory))
      copy_fixture_file("plaintext.txt", process_step.send(:working_directory))
    end

    context 'when there is an output file' do
      let!(:download_params) {
        {
            id: process_chain.id,
            relative_path: "plaintext.txt"
        }
      }

      specify do
        request_with_auth(user.create_new_auth_token) do
          perform_download_output_file_request(download_params)
        end
      end
    end

    context 'if no filename is supplied' do
      let!(:download_params) {
        {
            id: process_chain.id,
            relative_path: nil
        }
      }

      it 'fails' do
        request_with_auth(user.create_new_auth_token) do
          expect{perform_download_output_file_request(download_params)}.to raise_error("Please provide a relative file path")
        end
      end
    end

    context 'if a directory is supplied' do
      let!(:download_params) {
        {
            id: process_chain.id,
            relative_path: "/"
        }
      }

      it 'fails' do
        request_with_auth(user.create_new_auth_token) do
          expect{perform_download_output_file_request(download_params)}.to raise_error("Cannot find /")
        end
      end
    end

    context 'if the user tries to access a file up the file tree' do
      context 'for an absolute file path' do
        let!(:download_params) {
          {
              id: process_chain.id,
              relative_path: "/etc/important.config.file"
          }
        }

        it "doesn't allow access" do
          request_with_auth(user.create_new_auth_token) do
            expect{perform_download_output_file_request(download_params)}.to raise_error("Cannot find /etc/important.config.file")
          end
        end
      end

      context 'for a relative file path' do
        let!(:download_params) {
          {
              id: process_chain.id,
              relative_path: "../../important.config.file"
          }
        }
        it "doesn't allow access" do
          request_with_auth(user.create_new_auth_token) do
            expect{perform_download_output_file_request(download_params)}.to raise_error("Cannot find ../../important.config.file")
          end
        end
      end
    end

    context 'if a nonexistent file is supplied' do
      let!(:download_params) {
        {
            id: process_chain.id,
            relative_path: "rubbish.whatever"
        }
      }

      it 'fails' do
        request_with_auth(user.create_new_auth_token) do
          expect{perform_download_output_file_request(download_params)}.to raise_error("Cannot find rubbish.whatever")
        end
      end
    end

  end

  describe "GET download_input_file" do

    context 'when there is an input file' do
      let!(:download_params) {
        {
            id: process_chain.id,
            relative_path: "plaintext.txt"
        }
      }

      specify do
        request_with_auth(user.create_new_auth_token) do
          perform_download_input_file_request(download_params)
        end
      end
    end

    context 'if no filename is supplied' do
      let!(:download_params) {
        {
            id: process_chain.id,
            relative_path: nil
        }
      }

      it 'fails' do
        request_with_auth(user.create_new_auth_token) do
          expect{perform_download_input_file_request(download_params)}.to raise_error("Please provide a relative file path")
        end
      end
    end

    context 'if a directory is supplied' do
      let!(:download_params) {
        {
            id: process_chain.id,
            relative_path: "/"
        }
      }

      it 'fails' do
        request_with_auth(user.create_new_auth_token) do
          expect{perform_download_input_file_request(download_params)}.to raise_error("Cannot find /")
        end
      end
    end

    context 'if a nonexistent file is supplied' do
      let!(:download_params) {
        {
            id: process_chain.id,
            relative_path: "rubbish.whatever"
        }
      }

      it 'fails' do
        request_with_auth(user.create_new_auth_token) do
          expect{perform_download_input_file_request(download_params)}.to raise_error("Cannot find rubbish.whatever")
        end
      end
    end
  end

  describe "GET retry" do

    context 'if a valid token is supplied' do
      context 'if the chain belongs to that user' do
        context 'if a file is supplied' do
          context 'if the recipe has no steps' do
            before do
              recipe_step.destroy
            end

            it 'fails' do
              request_with_auth(user.create_new_auth_token) do
                perform_retry_request(params)
              end

              expect(response.status).to eq 422
            end
          end

          context 'if the recipe has steps' do
           specify do
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
      it 'fails' do
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

  def perform_download_input_file_request(data = {})
    download_input_file(version, data)
  end

  def perform_download_input_zip_request(data = {})
    download_input_zip(version, data)
  end

  def perform_download_output_file_request(data = {})
    download_output_file(version, data)
  end

  def perform_download_output_zip_request(data = {})
    download_output_zip(version, data)
  end
end