require_relative 'version'

describe Api::V1::ProcessStepsController, type: :controller do

  let(:process_log)         { ["Nothing happened", "Delightful process", "Would process again A+++++"] }
  let!(:account)            { create(:account, password: "password", password_confirmation: "password") }
  let!(:process_step)       { create(:process_step, process_log: process_log) }
  let(:process_chain)       { process_step.process_chain }
  let!(:working_directory)  { process_step.working_directory }

  before do
    process_chain.update_attribute(:account_id, account.id)
    process_step.update_attribute(:finished_at, 5.minutes.ago)

  end

  describe "GET download_output_zip" do

    let!(:download_params) {
      {
          id: process_step.id,
          relative_path: "some_text.txt"
      }
    }

    before do
      create_directory_if_needed(working_directory)
      copy_fixture_file('some_text.txt', working_directory)
      process_step.process_chain.update_attribute(:account_id, account.id)
      process_step.process_chain.recipe.update_attribute(:account_id, account.id)
    end

    context 'if a valid token is supplied' do
      context 'and the chain belongs to that account' do
        context 'and if the execution is finished' do
          before do
            process_step.update_attribute(:finished_at, 3.minutes.ago)
          end

          it 'serves the file successfully' do
            request_with_auth(account.new_jwt) do
              perform_download_output_zip_request(download_params)
            end

            expect(response.status).to eq 200
            expect(response.stream.to_path).to eq "/tmp/step_#{process_step.id}_output.zip"
          end
        end
        context 'and the execution is not finished' do
          before do
            process_step.update_attribute(:finished_at, nil)
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

    let!(:download_params) {
      {
          id: process_step.id,
          relative_path: "some_text.txt"
      }
    }

    before do
      process_step.update_attribute(:finished_at, 2.minutes.ago)
      create_directory_if_needed(working_directory)
      copy_fixture_file('some_text.txt', working_directory)
      process_step.process_chain.update_attribute(:account_id, account.id)
      process_step.process_chain.recipe.update_attribute(:account_id, account.id)
    end

    context 'if a valid token is supplied' do

      context 'and the file belongs to that account' do
        it 'serves the file successfully' do
          request_with_auth(account.new_jwt) do
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
          request_with_auth(account.new_jwt) do
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

  def perform_download_log_request(data = {})
    download_process_log(version, data)
  end

end