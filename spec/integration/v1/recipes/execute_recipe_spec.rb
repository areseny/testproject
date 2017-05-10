require 'rails_helper'
require_relative '../version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe "Account executes a single recipe" do

  let!(:rot13)      { rot_thirteen_step_class.to_s }

  # URL: /api/recipes/:id/execute
  # Method: GET
  # Execute a specific recipe belonging to the current account

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: account@example.com, auth_token: asdf" -X POST --form "input_files=[@my-file.txt], callback_url=mysite.com/callback" http://localhost:3000/api/recipes/:id/execute

  describe "POST execute recipe" do

    let!(:account)          { create(:account, password: "password", password_confirmation: "password") }
    let!(:auth_headers)     { account.new_jwt }
    let!(:text_file)        { fixture_file_upload('files/plaintext.txt', 'text/plaintext') }
    let!(:image_file)       { fixture_file_upload('files/kitty.jpeg', 'image/jpeg') }

    let!(:recipe)           { create(:recipe, account: account, step_classes: [rot13, rot13]) }

    context 'if account is signed in' do
      context 'and the recipe exists' do
        context 'and it belongs to the account' do
          context 'and a single file is supplied' do
            context 'and it has steps' do
              let!(:step1)      { recipe.recipe_steps[0] }
              let!(:step2)      { recipe.recipe_steps[1] }
              let(:gem_version) { "0.0.4" }
              let(:base_gem_version) { "1.0.1" }

              before do
                allow_any_instance_of(rot_thirteen_step_class).to receive(:version).and_return(gem_version)
                allow_any_instance_of(base_step_class).to receive(:version).and_return(base_gem_version)
              end

              context 'and a single file is supplied' do
                let(:params) {{
                    input_files: [text_file],
                    id: recipe.id
                }}

                before do
                  perform_execute_request(auth_headers, params)
                end

                it 'returns the objects' do
                  expect(response.status).to eq(200)
                  expect(body_as_json['process_chain']['process_steps'].sort_by{|e| e['position'].to_i}.map{|e| e['successful']}).to eq [true, true]
                  expect(body_as_json['process_chain']['process_steps'].count).to eq 2
                  body_as_json['process_chain']['process_steps'].map do |s|
                    expect(s['execution_errors']).to eq ""
                  end
                  # expect(body_as_json['process_chain']['process_steps'].sort_by{|e| e['position'].to_i}.map{|e| e['output_file_path']}).to eq [true, true]
                end

                it 'returns a ProcessChain object' do
                  process_chain = recipe.reload.process_chains.first

                  expect(body_as_json['process_chain']['recipe_id']).to eq process_chain.recipe_id
                  expect(body_as_json['process_chain']['executed_at']).to eq process_chain.executed_at.iso8601
                  expect(body_as_json['process_chain']['input_file_manifest']).to match([{"path"=>"plaintext.txt", "size"=>"18 bytes"}])
                  expect(body_as_json['process_chain']['output_file_manifest']).to match([{"path"=>"plaintext_rot13_rot13.txt", "size"=>"18 bytes"}])
                end

                it 'also returns the steps' do
                  expect(body_as_json['process_chain']['process_steps'].count).to eq 2
                  expect(body_as_json['process_chain']['process_steps'].sort_by{|e| e['position'].to_i}.map{|e| e['version']}).to eq [gem_version, gem_version]
                end

                it 'returns an input file manifest' do
                  expect(body_as_json['process_chain']['input_file_manifest']).to match([{'size' => "18 bytes", 'path' => "plaintext.txt"}])
                end

                it 'returns an output file manifest' do
                  expect(body_as_json['process_chain']['output_file_manifest']).to match([{"path"=>"plaintext_rot13_rot13.txt", "size"=>"18 bytes"}])
                end
              end

              context 'and execution fails' do
                let(:params) {{
                    id: recipe.id,
                    input_files: [text_file]
                }}

                before do
                  allow_any_instance_of(base_step_class).to receive(:perform_step) { raise "Oh noes! Error!" }
                end

                it 'returns the errors' do
                  perform_execute_request(auth_headers, params)

                  expect(response.status).to eq(200)
                  expect(body_as_json['process_chain']['process_steps'].count).to eq 2
                end
              end
            end
          end

          context 'and multiple files are supplied' do
            let(:params) {{
                id: recipe.id,
                input_files: [text_file, image_file]
            }}

            it 'returns the objects' do
              perform_execute_request(auth_headers, params)

              expect(response.status).to eq(200)
              expect(body_as_json['process_chain']['process_steps'].count).to eq 2
              body_as_json['process_chain']['process_steps'].map do |s|
                expect(s['execution_errors']).to eq ""
              end
              expect(body_as_json['process_chain']['executed_at']).to_not be_nil
              expect(body_as_json['process_chain']['finished_at']).to_not be_nil
              expect(body_as_json['process_chain']['input_file_manifest']).to match([{"path"=>"kitty.jpeg", "size"=>"21.6 kB"}, {"path"=>"plaintext.txt", "size"=>"18 bytes"}])
              expect(body_as_json['process_chain']['output_file_manifest']).to match([{"path"=>"kitty.jpeg", "size"=>"21.6 kB"}, {"path"=>"plaintext_rot13_rot13.txt", "size"=>"18 bytes"}])
            end
          end

          context 'and no file is supplied' do
            let(:params) {{
                id: recipe.id,
                input_files: []
            }}

            it 'returns an error' do
              perform_execute_request(auth_headers, params)

              expect(response.status).to eq(422)
            end
          end
        end

        context 'and it belongs to a different account' do

          let!(:other_account)     { create(:account) }
          let(:params) {{
              input_files: [text_file],
              id: recipe.id
          }}

          before do
            recipe.update_attribute(:account_id, other_account.id)
          end

          it 'responds with failure' do
            perform_execute_request(auth_headers, params)
            expect(response.status).to eq(404)
          end
        end
      end

      context 'and the recipe does not exist' do
        let(:params) {{
            input_files: [text_file],
            id: recipe.id
        }}

        before do
          recipe.destroy
          perform_execute_request(auth_headers, params)
        end

        it 'responds with failure' do
          expect(response.status).to eq(404)
        end
      end
    end

    context 'if no account is signed in' do
      let(:params) {{
          input_files: [text_file],
          id: recipe.id
      }}

      before do
        perform_execute_request({}, params)
      end

      it 'raises an error' do
        expect(response.status).to eq(401)
      end

      it 'provides a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end

    xcontext 'if the token has expired' do
      let(:params) {{
          input_files: [text_file],
          id: recipe.id
      }}

      before do
        expire_token(account, auth_headers['client'])
        perform_execute_request({}, params)
      end

      it 'raises an error' do
        expect(response.status).to eq(401)
      end

      it 'provides a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end

  end
  
  def perform_execute_request(auth_headers, data)
    execute_recipe_request(version, auth_headers, data)
  end
end