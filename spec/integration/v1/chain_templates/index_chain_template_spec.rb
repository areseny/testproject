require 'rails_helper'

describe "User lists all their chain templates" do

  # URL: /api/chain_templates/
  # Method: GET
  # Get all the chain templates belonging to the current user

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X GET http://localhost:3000/api/chain_templates

  describe "GET index chain template" do

    let!(:user)               { FactoryGirl.create(:user, password: "password", password_confirmation: "password") }
    let!(:other_user)         { FactoryGirl.create(:user) }

    let!(:auth_headers)       { user.create_new_auth_token }
    let!(:template)           { FactoryGirl.create(:chain_template, user: user) }
    let!(:inactive_template)  { FactoryGirl.create(:chain_template, user: user, active: false) }
    let!(:other_template)     { FactoryGirl.create(:chain_template, user: other_user) }

    context 'if user is signed in' do

      context 'and there are some active chain templates that belong to the user' do

        before do
          perform_index_request(auth_headers)
        end

        it 'responds with success' do
          expect(response.status).to eq(200)
        end

        it 'should return a list of ChainTemplate objects' do
          expect(body_as_json.count).to eq 1

          expect(body_as_json[0]['name']).to eq template.name
          expect(body_as_json[0]['description']).to eq template.description
          expect(body_as_json[0]['user_id']).to eq template.user.id
          expect(body_as_json[0]['active']).to eq template.active
        end
      end

      context 'and there are no active chain templates that belong to the current user' do

        before do
          template.destroy
          perform_index_request(auth_headers)
        end

        it 'responds with success' do
          expect(response.status).to eq(200)
        end

        it 'responds with an empty set' do
          expect(body_as_json.to_a).to eq []
        end
      end
    end

    context 'if no user is signed in' do
      before do
        perform_index_request({})
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
        perform_index_request({})
      end

      it 'should raise an error' do
        expect(response.status).to eq(401)
      end

      it 'should provide a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end

  end
  
  def perform_index_request(auth_headers)
    index_chain_template_request('v1', auth_headers)
  end
end