require_relative 'version'

describe Api::V1::ProcessStepsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let!(:user)           { create(:user, password: "password", password_confirmation: "password") }

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
      process_step.process_chain.update_attribute(:user_id, user.id)
      process_step.process_chain.recipe.update_attribute(:user_id, user.id)
    end

    context 'if a valid token is supplied' do

      context 'and the file belongs to that user' do
        it 'serves the file successfully' do
          request_with_auth(user.create_new_auth_token) do
            perform_download_output_file_request(download_params)
          end

          expect(response.status).to eq 200
          expect(assigns(:process_step)).to_not be_nil
        end
      end

      context 'and the file belongs to a different user' do
        before do
          other_user = create(:user)
          process_step.process_chain.update_attribute(:user_id, other_user.id)
        end

        it 'tries to download the file' do
          request_with_auth(user.create_new_auth_token) do
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