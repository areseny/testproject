require 'rails_helper'

describe "User archives a single chain template" do

  # URL: /api/chain_template/:id
  # Method: DELETE
  # Get a specific template belonging to the current user

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X GET http://localhost:3000/api/chain_templates/:id

  describe "GET archive chain template" do

    let!(:user)             { FactoryGirl.create(:user, password: "password", password_confirmation: "password") }
    let!(:auth_headers)     { user.create_new_auth_token }

    let!(:template)         { FactoryGirl.create(:chain_template, user: user) }

    context 'if user is signed in' do

      context 'and the chain template exists' do

        before do
          perform_archive_request(auth_headers, template.id)
        end

        context 'and it belongs to the user' do
          it 'responds with success' do
            expect(response.status).to eq(200)
          end

          it 'should return a ChainTemplate object' do
            expect(body_as_json['name']).to eq template.name
            expect(body_as_json['description']).to eq template.description
            expect(body_as_json['user_id']).to eq template.user.id
            expect(body_as_json['active']).to eq template.active
          end
        end

        context 'and it belongs to a different user' do
          let!(:other_user)     { FactoryGirl.create(:user) }

          before do
            template.update_attribute(:user_id, other_user.id)
          end

          it 'responds with failure' do
            perform_archive_request(auth_headers, template.id)
            expect(response.status).to eq(404)
          end
        end
      end

      context 'and the chain template does not exist' do

        before do
          template.destroy
          perform_archive_request(auth_headers, "rubbish")
        end

        it 'responds with failure' do
          expect(response.status).to eq(404)
        end
      end
    end

    context 'if no user is signed in' do
      before do
        perform_archive_request({}, template.id)
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
        perform_archive_request({}, template.id)
      end

      it 'should raise an error' do
        expect(response.status).to eq(401)
      end

      it 'should provide a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end

  end
  
  def perform_archive_request(auth_headers, id)
    archive_chain_template_request('v1', auth_headers, id)
  end
end