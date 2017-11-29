require 'rails_helper'
require_relative 'version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe Api::V1::SingleStepExecutionsController, type: :controller do

  let!(:account)                { create(:account, password: "password", password_confirmation: "password") }
  let!(:text_file)              { File.new('spec/fixtures/files/plaintext.txt', 'r') }
  let!(:single_step_execution)  {
    create(:single_step_execution, account: account, step_class_name: "InkStep::Base")
  }

  let!(:params) {
    {
        id: single_step_execution.id
    }
  }

  before do
    single_step_execution.initialize_directories
    copy_fixture_file("plaintext.txt", single_step_execution.input_files_directory)
  end

  describe "POST create" do

    let(:description)           { "A most splendid class, you should look at it" }
    let(:step_class_name)       { "InkStep::AwesomeClass" }
    let(:execution_parameters)  { {"stuff" => "things"} }
    let(:html_file)             { fixture_file_upload('files/test_file.xml', 'text/xml') }
    let(:klass_file)            { File.read(Rails.root.join('spec/fixtures/files/standalone/awesome_class.rb')) }

    let!(:single_step_execution_params) {
      {
          single_step_execution: {
              description: description,
              step_class_name: step_class_name,
              execution_parameters: execution_parameters,
              input_files: html_file,
              code: klass_file
          }
      }
    }

    context 'if a valid token is supplied' do
      context 'if the single_step_execution is valid' do
        it "creates the single_step_execution" do
          request_with_auth(account.new_jwt) do
            perform_create_request(single_step_execution_params)
          end

          expect(response.status).to eq 200
          new_single_step_execution = assigns[:single_step_execution]
          expect(new_single_step_execution).to be_a SingleStepExecution
          expect(new_single_step_execution.description).to eq description
          expect(new_single_step_execution.account).to eq account
          expect(new_single_step_execution.step_class_name).to eq step_class_name
          expect(new_single_step_execution.execution_parameters).to eq execution_parameters
        end
      end

      context 'if the single_step_execution is invalid' do

        context 'if the code supplied is blank' do
          before do
            single_step_execution_params[:code] = File.read(Rails.root.join('spec/fixtures/files/standalone/blank_file.rb'))
          end

          specify do
            request_with_auth(account.new_jwt) do
              perform_create_request(single_step_execution_params)
            end

            expect(response.status).to eq 422
            expect(body_as_json['errors']).to eq ["That file does not define the class InkStep::AwesomeClass"]
          end
        end

        context 'if the code supplied does not contain a class' do
          before do
            single_step_execution_params[:code] = File.read(Rails.root.join('spec/fixtures/files/standalone/valid_not_a_class.rb'))
          end

          specify do
            request_with_auth(account.new_jwt) do
              perform_create_request(single_step_execution_params)
            end

            expect(response.status).to eq 422
            expect(body_as_json['errors']).to eq ["Mismatch! You provided InkStep::AwesomeClass and the file defined something else"]
          end
        end

        context 'if the code supplied is not valid syntax' do
          before do
            single_step_execution_params[:code] = File.read(Rails.root.join('spec/fixtures/files/standalone/rubbish_class'))
          end

          specify do
            request_with_auth(account.new_jwt) do
              perform_create_request(single_step_execution_params)
            end

            expect(response.status).to eq 422
            expect(body_as_json['errors']).to eq ["Syntax error - InkStep::AwesomeClass could not be loaded"]
          end
        end

        context 'if the single_step_execution is missing a field' do
          before do
            single_step_execution_params[:single_step_execution].delete(:description)
          end

          specify do
            request_with_auth(account.new_jwt) do
              perform_create_request(single_step_execution_params)
            end

            expect(response.status).to eq 422
            expect(body_as_json['errors']).to eq ["Validation failed: Description can't be blank"]
          end
        end
      end
    end

    context 'if no valid token is supplied' do

      it "does not assign anything" do
        request_with_auth do
          perform_create_request(single_step_execution_params)
        end

        expect(response.status).to eq 401
        expect(assigns[:new_single_step_execution]).to be_nil
      end
    end
  end

  describe "GET download_input_zip" do
    let!(:download_params) {
      {
          id: single_step_execution.id
      }
    }

    context 'if a valid token is supplied' do
      context 'and the chain belongs to that account' do
        it 'serves the file successfully' do
          request_with_auth(account.new_jwt) do
            perform_download_input_zip_request(download_params)
          end

          expect(response.status).to eq 200
          expect(response.stream.to_path).to eq "/tmp/chain_#{single_step_execution.id}_input.zip"
        end
      end
    end
  end

  describe "GET download_output_zip" do
    let!(:download_params) {
      {
          id: single_step_execution.id
      }
    }

    before do
      create_directory_if_needed(single_step_execution.working_directory)
      copy_fixture_file('some_text.txt', single_step_execution.working_directory)
    end

    context 'if a valid token is supplied' do
      context 'and the chain belongs to that account' do
        context 'and exeuction is finished' do
          it 'serves the file successfully' do
            request_with_auth(account.new_jwt) do
              perform_download_output_zip_request(download_params)
            end

            expect(response.status).to eq 200
            expect(response.stream.to_path).to eq "/tmp/step_#{single_step_execution.last_step.id}_output.zip"
          end
        end
        context 'and the execution is not finished' do
          before do
            single_step_execution.update_attribute(:finished_at, nil)
          end

          it 'returns 404' do
            request_with_auth(account.new_jwt) do
              perform_download_output_zip_request(download_params)
            end

            expect(response.status).to eq 404
          end
        end
      end
    end
  end

  describe "GET download_output_file" do

    before do
      create_directory_if_needed(single_step_execution.send(:working_directory))
      copy_fixture_file("plaintext.txt", single_step_execution.send(:working_directory))
    end

    context 'when there is an output file' do
      let!(:download_params) {
        {
            id: single_step_execution.id,
            relative_path: "plaintext.txt"
        }
      }

      context 'when execution is finished' do
        it 'downloads the file' do
          request_with_auth(account.new_jwt) do
            perform_download_output_file_request(download_params)
          end

          expect(response.status).to eq 200
        end
      end
      context 'and the execution is not finished' do
        before do
          single_step_execution.update_attribute(:finished_at, nil)
        end

        it 'returns 404' do
          request_with_auth(account.new_jwt) do
            perform_download_output_zip_request(download_params)
          end

          expect(response.status).to eq 404
        end
      end
    end

    context 'if no filename is supplied' do
      let!(:download_params) {
        {
            id: single_step_execution.id,
            relative_path: nil
        }
      }

      it 'fails' do
        request_with_auth(account.new_jwt) do
          expect{perform_download_output_file_request(download_params)}.to raise_error("Please provide a relative file path")
        end
      end
    end

    context 'if a directory is supplied' do
      let!(:download_params) {
        {
            id: single_step_execution.id,
            relative_path: "/"
        }
      }

      it 'fails' do
        request_with_auth(account.new_jwt) do
          expect{perform_download_output_file_request(download_params)}.to raise_error("Cannot find /")
        end
      end
    end

    context 'if the account tries to access a file up the file tree' do
      context 'for an absolute file path' do
        let!(:download_params) {
          {
              id: single_step_execution.id,
              relative_path: "/etc/important.config.file"
          }
        }

        it "doesn't allow access" do
          request_with_auth(account.new_jwt) do
            expect{perform_download_output_file_request(download_params)}.to raise_error("Cannot find /etc/important.config.file")
          end
        end
      end

      context 'for a relative file path' do
        let!(:download_params) {
          {
              id: single_step_execution.id,
              relative_path: "../../important.config.file"
          }
        }
        it "doesn't allow access" do
          request_with_auth(account.new_jwt) do
            expect{perform_download_output_file_request(download_params)}.to raise_error("Cannot find ../../important.config.file")
          end
        end
      end
    end

    context 'if a nonexistent file is supplied' do
      let!(:download_params) {
        {
            id: single_step_execution.id,
            relative_path: "rubbish.whatever"
        }
      }

      it 'fails' do
        request_with_auth(account.new_jwt) do
          expect{perform_download_output_file_request(download_params)}.to raise_error("Cannot find rubbish.whatever")
        end
      end
    end

  end

  describe "GET download_input_file" do

    context 'when there is an input file' do
      let!(:download_params) {
        {
            id: single_step_execution.id,
            relative_path: "plaintext.txt"
        }
      }

      specify do
        request_with_auth(account.new_jwt) do
          perform_download_input_file_request(download_params)
        end
      end
    end

    context 'if no filename is supplied' do
      let!(:download_params) {
        {
            id: single_step_execution.id,
            relative_path: nil
        }
      }

      it 'fails' do
        request_with_auth(account.new_jwt) do
          expect{perform_download_input_file_request(download_params)}.to raise_error("Please provide a relative file path")
        end
      end
    end

    context 'if a directory is supplied' do
      let!(:download_params) {
        {
            id: single_step_execution.id,
            relative_path: "/"
        }
      }

      it 'fails' do
        request_with_auth(account.new_jwt) do
          expect{perform_download_input_file_request(download_params)}.to raise_error("Cannot find /")
        end
      end
    end

    context 'if a nonexistent file is supplied' do
      let!(:download_params) {
        {
            id: single_step_execution.id,
            relative_path: "rubbish.whatever"
        }
      }

      it 'fails' do
        request_with_auth(account.new_jwt) do
          expect{perform_download_input_file_request(download_params)}.to raise_error("Cannot find rubbish.whatever")
        end
      end
    end
  end

  def perform_show_request(data = {})
    get_show_request(version, data)
  end

  def perform_create_request(data = {})
    post_create_request(version, data)
  end

  def perform_update_request(data)
    put_update_request(version, data)
  end

  def perform_index_request(data = {})
    get_index_request(version, data)
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

  def perform_retry_request(data = {})
    retry_execution(version, data)
  end
end