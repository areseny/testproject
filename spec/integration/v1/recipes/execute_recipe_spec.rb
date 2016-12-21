require 'rails_helper'
require_relative '../version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe "User executes a single recipe" do

  # URL: /api/recipes/:id/execute
  # Method: GET
  # Execute a specific recipe belonging to the current user

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X POST --form "input_file=@my-file.txt, callback_url=mysite.com/callback" http://localhost:3000/api/recipes/:id/execute

  describe "POST execute recipe" do

    let!(:user)             { create(:user, password: "password", password_confirmation: "password") }
    let!(:auth_headers)     { user.create_new_auth_token }
    let!(:text_file)        { fixture_file_upload('files/plaintext.txt', 'text/plaintext') }

    let!(:recipe)           { create(:recipe, user: user) }

    let!(:execution_params) {
      {
          input_file: text_file,
          id: recipe.id
      }
    }

    context 'if user is signed in' do
      context 'and the recipe exists' do
        context 'and it belongs to the user' do
          context 'and a file is supplied' do
            context 'and it has no steps' do
              it 'responds with failure' do
                perform_execute_request(auth_headers, execution_params)

                expect(response.status).to eq(422)
              end
            end

            context 'and it has steps' do
              let!(:rot13)      { rot_thirteen_step_class.to_s }
              let!(:step1)      { create(:recipe_step, recipe: recipe, position: 1, step_class_name: rot13) }
              let!(:step2)      { create(:recipe_step, recipe: recipe, position: 2, step_class_name: rot13) }
              let(:gem_version) { "0.0.4" }
              let(:base_gem_version) { "1.0.1" }

              before do
                allow_any_instance_of(rot_thirteen_step_class).to receive(:version).and_return(gem_version)
                allow_any_instance_of(base_step_class).to receive(:version).and_return(base_gem_version)
              end

              context 'and execution is successful' do
                it 'returns the objects' do
                  perform_execute_request(auth_headers, execution_params)

                  expect(response.status).to eq(200)
                  expect(body_as_json['process_chain']['successful'])
                  expect(body_as_json['process_chain']['process_steps'].count).to eq 2
                  body_as_json['process_chain']['process_steps'].map do |s|
                    expect(s['execution_errors']).to eq ""
                  end
                  # expect(body_as_json['process_chain']['process_steps'].sort_by{|e| e['position'].to_i}.map{|e| e['output_file_path']}).to eq [true, true]
                end

                it 'returns a ProcessChain object' do
                  perform_execute_request(auth_headers, execution_params)

                  process_chain = recipe.reload.process_chains.first

                  expect(body_as_json['process_chain']['recipe_id']).to eq process_chain.recipe_id
                  expect(body_as_json['process_chain']['executed_at']).to eq process_chain.executed_at.iso8601
                  expect(body_as_json['process_chain']['input_file_manifest']).to eq process_chain.input_file_manifest
                  expect(body_as_json['process_chain']['executed_at_for_humans']).to_not be_nil
                  expect(body_as_json['process_chain']['successful']).to eq true
                  expect(body_as_json['process_chain']['input_file_manifest']).to eq ["plaintext.txt"]
                  expect(body_as_json['process_chain']['output_file_manifest']).to eq ["plaintext_rot13_rot13.txt"]
                end

                it 'also returns the steps' do
                  perform_execute_request(auth_headers, execution_params)

                  ap body_as_json
                  expect(body_as_json['process_chain']['process_steps'].count).to eq 2
                  expect(body_as_json['process_chain']['process_steps'].sort_by{|e| e['position'].to_i}.map{|e| e['version']}).to eq [gem_version, gem_version]
                end
              end

              context 'and execution fails' do
                before do
                  allow_any_instance_of(base_step_class).to receive(:perform_step) { raise "Oh noes! Error!" }
                end

                it 'returns the errors' do
                  perform_execute_request(auth_headers, execution_params)

                  expect(response.status).to eq(200)
                  expect(body_as_json['process_chain']['process_steps'].sort_by{|e| e['position'].to_i}.map{|e| e['execution_errors']}).to eq ["Oh noes! Error!", ""]
                  expect(body_as_json['process_chain']['successful']).to eq false
                  expect(body_as_json['process_chain']['process_steps'].count).to eq 2
                end
              end
            end
          end

          context 'and no file is supplied' do
            before do
              # execution_params[:input_file] = nil #this causes a JSON parse error!
              execution_params.delete(:input_file)
            end

            it 'returns an error' do
              perform_execute_request(auth_headers, execution_params)

              expect(response.status).to eq(422)
            end
          end
        end

        context 'and it belongs to a different user' do

          let!(:other_user)     { create(:user) }

          before do
            recipe.update_attribute(:user_id, other_user.id)
          end

          it 'responds with failure' do
            perform_execute_request(auth_headers, execution_params)
            expect(response.status).to eq(404)
          end
        end
      end

      context 'and the recipe does not exist' do

        before do
          recipe.destroy
          perform_execute_request(auth_headers, execution_params)
        end

        it 'responds with failure' do
          expect(response.status).to eq(404)
        end
      end
    end

    context 'if no user is signed in' do
      before do
        perform_execute_request({}, execution_params)
      end

      it 'raises an error' do
        expect(response.status).to eq(401)
      end

      it 'provides a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end

    context 'if the token has expired' do
      before do
        expire_token(user, auth_headers['client'])
        perform_execute_request({}, execution_params)
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