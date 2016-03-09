require 'rails_helper'

describe "User creates chain template" do

  # URL: /api/chain_templates
  # Method: POST
  # Use this route to end the user's current session. This route will invalidate the user's authentication token.

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X POST http://localhost:3000/api/chain_templates

  describe "POST create new chain template" do

    let!(:user)             { FactoryGirl.create(:user, password: "password", password_confirmation: "password") }
    let!(:name)             { "My Splendiferous PNG to JPG transmogrifier" }
    let!(:description)      { "It transmogrifies! It transforms! It even goes across filetypes!" }
    let!(:auth_headers)     { user.create_new_auth_token }

    let!(:chain_template_params) {
      {
          chain_template: {
              name: name,
              description: description,
              uid: user.email
          }
      }
    }

    context 'if user is signed in' do

      before do
        perform_create_request(auth_headers, chain_template_params.to_json)
      end

      it 'responds with success' do
        expect(response.status).to eq(200)
      end

      it 'should return a ChainTemplate object' do
        expect(body_as_json['name']).to eq name
        expect(body_as_json['description']).to eq description
        expect(body_as_json['user_id']).to eq user.id
        expect(body_as_json['active']).to eq true
      end

      it 'should create a new chain template with the parameters' do
        expect(user.reload.chain_templates.count).to eq 1

        template = user.chain_templates.first
        expect(template.user).to eq user
        expect(template.name).to eq name
        expect(template.description).to eq description
        expect(template.active).to be_truthy
      end
    end

    context 'if no user is signed in' do
      before do
        perform_create_request({}, chain_template_params.to_json)
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
        perform_create_request({}, chain_template_params.to_json)
      end

      it 'should raise an error' do
        expect(response.status).to eq(401)
      end

      it 'should provide a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end

  end
  
  def perform_create_request(auth_headers, data)
    create_chain_template_request('v1', auth_headers, data)
  end
end