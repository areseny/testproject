require_relative 'version'

describe Api::V1::ProcessStepsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let!(:account)           { create(:account, password: "password", password_confirmation: "password") }

  describe "GET download_output_zip" do
    let!(:process_step)        { create(:process_step) }

    let!(:download_params) {
      {
          id: process_step.id,
          relative_path: "some_text.txt"
      }
    }

    before do
      create_directory_if_needed(process_step.working_directory)
      copy_fixture_file('some_text.txt', process_step.working_directory)
      process_step.process_chain.update_attribute(:account_id, account.id)
      process_step.process_chain.recipe.update_attribute(:account_id, account.id)
    end

    context 'if a valid token is supplied' do
      context 'and the chain belongs to that account' do
        it 'serves the file successfully' do
          request_with_auth(account.create_new_auth_token) do
            perform_download_output_zip_request(download_params)
          end

          expect(response.status).to eq 200
          expect(response.stream.to_path).to eq "/tmp/step_#{process_step.id}_output.zip"
        end
      end
    end
  end

  describe "GET download_output_file" do

    let!(:process_step)        { create(:process_step) }

    let!(:download_params) {
      {
          id: process_step.id,
          relative_path: "some_text.txt"
      }
    }

    before do
      create_directory_if_needed(process_step.working_directory)
      copy_fixture_file('some_text.txt', process_step.working_directory)
      process_step.process_chain.update_attribute(:account_id, account.id)
      process_step.process_chain.recipe.update_attribute(:account_id, account.id)
    end

    context 'if a valid token is supplied' do

      context 'and the file belongs to that account' do
        it 'serves the file successfully' do
          request_with_auth(account.create_new_auth_token) do
            perform_download_output_file_request(download_params)
          end

          expect(response.status).to eq 200
          expect(assigns(:process_step)).to_not be_nil
        end
      end

      context 'and the file belongs to a different account' do
        before do
          other_account = create(:account)
          process_step.process_chain.update_attribute(:account_id, other_account.id)
        end

        it 'tries to download the file' do
          request_with_auth(account.create_new_auth_token) do
            perform_download_output_file_request(download_params)
          end

          expect(response.status).to eq 401
        end
      end

    end

    context 'if no valid token is supplied' do

      it "does not assign anything" do
        request_with_auth do
          perform_download_output_file_request(download_params)
        end

        expect(response.status).to eq 401
      end
    end
  end

  def perform_download_output_file_request(data = {})
    download_output_file(version, data)
  end

  def perform_download_output_zip_request(data = {})
    download_output_zip(version, data)
  end

end