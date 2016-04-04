require 'rails_helper'

describe "User executes a single chain template" do

  # URL: /api/recipes/:id/execute
  # Method: GET
  # Get a specific template belonging to the current user

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X GET http://localhost:3000/api/recipes/:id/execute

  describe "POST execute chain template" do

    let!(:user)             { FactoryGirl.create(:user, password: "password", password_confirmation: "password") }
    let!(:auth_headers)     { user.create_new_auth_token }
    let!(:xml_file)         { fixture_file_upload('spec/fixtures/files/test_file.xml', 'text/xml') }
    let!(:photo_file)       { fixture_file_upload('spec/fixtures/files/kitty.jpeg', 'image/jpeg') }

    let!(:recipe)   { FactoryGirl.create(:recipe, user: user) }

    let!(:execution_params) {
      {
          input_file: photo_file,
          id: recipe.id
      }
    }

    context 'if user is signed in' do

      context 'and the chain template exists' do

        context 'and it belongs to the user' do

          context 'and a file is supplied' do

            it 'responds with success' do
              perform_execute_request(auth_headers, execution_params)

              expect(response.status).to eq(200)
            end

            it 'should return a ConversionChain object' do
              perform_execute_request(auth_headers, execution_params)

              conversion_chain = recipe.reload.conversion_chains.first

              expect(body_as_json['conversion_chain']['recipe_id']).to eq conversion_chain.recipe_id
              expect(body_as_json['conversion_chain']['executed_at']).to eq conversion_chain.executed_at.iso8601
              expect(body_as_json['conversion_chain']['input_file_name']).to eq conversion_chain.input_file_name
            end

            context 'and it has steps' do
              let!(:jpg_class)  { FactoryGirl.create(:step_class, name: "JpgToPng") }
              let!(:step1)      { FactoryGirl.create(:step_template, recipe: recipe, position: 1, step_class: jpg_class) }
              let!(:step2)      { FactoryGirl.create(:step_template, recipe: recipe, position: 2, step_class: jpg_class) }

              it 'should also return the steps' do
                perform_execute_request(auth_headers, execution_params)

                expect(body_as_json['conversion_chain']['conversion_steps'].count).to eq 2
              end

              context 'and execution is successful' do
                it 'should return the objects' do
                  perform_execute_request(auth_headers, execution_params)

                  expect(response.status).to eq(200)
                  expect(body_as_json['conversion_chain']['conversion_steps'].count).to eq 2
                  expect(body_as_json['conversion_chain']['conversion_steps'].sort_by{|e| e['position'].to_i}.map{|e| e[:conversion_errors]}).to eq [nil, nil]
                end
              end

              context 'and execution fails' do

                let!(:steps)                  { [Conversion::Steps::JpgToPng] }
                let!(:boobytrapped_step)      { Conversion::Steps::JpgToPng.new }

                before do
                  expect(boobytrapped_step).to receive(:convert_file) { raise "Oh noes! Error!" }
                  allow(Conversion::Steps::JpgToPng).to receive(:new).and_return boobytrapped_step
                end

                it 'should return the errors' do
                  perform_execute_request(auth_headers, execution_params)

                  expect(response.status).to eq(200)
                  expect(body_as_json['conversion_chain']['conversion_steps'].count).to eq 2
                  expect(body_as_json['conversion_chain']['conversion_steps'].sort_by{|e| e['position'].to_i}.map{|e| e['conversion_errors']}).to eq [["Oh noes! Error!"].to_json, ["Oh noes! Error!"].to_json]
                end
              end
            end
          end

          context 'and no file is supplied' do
            before do
              # execution_params[:input_file] = nil #this causes a JSON parse error!
              execution_params.delete(:input_file)
            end

            it 'should return an error' do
              perform_execute_request(auth_headers, execution_params)

              expect(response.status).to eq(422)
            end
          end
        end

        context 'and it belongs to a different user' do

          let!(:other_user)     { FactoryGirl.create(:user) }

          before do
            recipe.update_attribute(:user_id, other_user.id)
          end

          it 'responds with failure' do
            perform_execute_request(auth_headers, execution_params)
            expect(response.status).to eq(404)
          end
        end
      end

      context 'and the chain template does not exist' do

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

      it 'should raise an error' do
        expect(response.status).to eq(401)
      end

      it 'should provide a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end

    context 'if the token has expired' do
      before do
        expire_token(user, auth_headers['client'])
        perform_execute_request({}, execution_params)
      end

      it 'should raise an error' do
        expect(response.status).to eq(401)
      end

      it 'should provide a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end

  end
  
  def perform_execute_request(auth_headers, data)
    execute_recipe_request(version, auth_headers, data)
  end

  def version
    'v1'
  end
end