require 'rails_helper'

describe "User executes a single chain template" do

  # URL: /api/chain_templates/:id/execute
  # Method: GET
  # Get a specific template belonging to the current user

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X GET http://localhost:3000/api/chain_templates/:id/execute

  describe "POST execute chain template" do

    let!(:user)             { FactoryGirl.create(:user, password: "password", password_confirmation: "password") }
    let!(:auth_headers)     { user.create_new_auth_token }
    let!(:xml_file)         { fixture_file_upload('spec/fixtures/files/test_file.xml', 'text/xml') }
    let!(:photo_file)       { fixture_file_upload('spec/fixtures/files/kitty.jpeg', 'image/jpeg') }

    let!(:chain_template)   { FactoryGirl.create(:chain_template, user: user) }

    let!(:execution_params) {
      {
          input_file: photo_file,
          id: chain_template.id
      }
    }

    context 'if user is signed in' do

      context 'and the chain template exists' do

        context 'and it belongs to the user' do
          it 'responds with success' do
            perform_execute_request(auth_headers, chain_template.id, execution_params)

            expect(response.status).to eq(200)
          end

          it 'should return a ConversionChain object' do
            perform_execute_request(auth_headers, chain_template.id, execution_params)

            conversion_chain = chain_template.reload.conversion_chains.first

            expect(body_as_json['conversion_chain']['chain_template_id']).to eq conversion_chain.chain_template_id
            expect(body_as_json['conversion_chain']['executed_at']).to eq conversion_chain.executed_at.iso8601
            expect(body_as_json['conversion_chain']['input_file_name']).to eq conversion_chain.input_file_name
          end

          context 'and it has steps' do
            let!(:step1)      { FactoryGirl.create(:step_template, chain_template: chain_template, position: 1) }
            let!(:step2)      { FactoryGirl.create(:step_template, chain_template: chain_template, position: 2) }

            it 'should also return the steps' do
              perform_execute_request(auth_headers, chain_template.id, execution_params)

              expect(body_as_json['conversion_chain']['conversion_steps'].count).to eq 2
            end
          end
        end

        context 'and it belongs to a different user' do

          let!(:other_user)     { FactoryGirl.create(:user) }

          before do
            chain_template.update_attribute(:user_id, other_user.id)
          end

          it 'responds with failure' do
            perform_execute_request(auth_headers, chain_template.id, execution_params)
            expect(response.status).to eq(404)
          end
        end
      end

      context 'and the chain template does not exist' do

        before do
          chain_template.destroy
          perform_execute_request(auth_headers, "rubbish", execution_params)
        end

        it 'responds with failure' do
          expect(response.status).to eq(404)
        end
      end
    end

    context 'if no user is signed in' do
      before do
        perform_execute_request({}, chain_template.id, execution_params)
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
        perform_execute_request({}, chain_template.id, execution_params)
      end

      it 'should raise an error' do
        expect(response.status).to eq(401)
      end

      it 'should provide a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end

  end
  
  def perform_execute_request(auth_headers, id, data)
    execute_chain_template_request(version, auth_headers, id, data)
  end

  def version
    'v1'
  end
end