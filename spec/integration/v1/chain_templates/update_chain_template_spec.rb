require 'rails_helper'

describe "User updates chain template" do

  # URL: /api/chain_templates/:id/
  # Method: PUT or PATCH
  # Use this route to end the user's current session. This route will invalidate the user's authentication token.

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X PUT http://localhost:3000/api/chain_templates/:id

  describe "PUT update chain template" do

    let!(:user)             { FactoryGirl.create(:user, password: "password", password_confirmation: "password") }
    let!(:name)             { "My Splendiferous PNG to JPG transmogrifier" }
    let!(:description)      { "It transmogrifies! It transforms! It even goes across filetypes!" }
    let!(:active)           { false }
    let!(:auth_headers)     { user.create_new_auth_token }
    let!(:chain_template)   { FactoryGirl.create(:chain_template, user: user) }

    let!(:chain_template_params) {
      {
          chain_template: {
              name: name,
              description: description,
              uid: user.email,
              active: active
          },
          id: chain_template.id
      }
    }

    let!(:chain_template_attributes){ [:name, :description, :active]  }

    context 'if user is signed in' do

      context 'and the chain template belongs to the user' do

        context 'if all attributes are supplied' do
          before do
            perform_update_request(auth_headers, chain_template.id, chain_template_params.to_json)
          end

          it 'responds with success' do
            expect(response.status).to eq(200)
          end

          it 'should return the updated ChainTemplate object' do
            expect(body_as_json['name']).to eq name
            expect(body_as_json['description']).to eq description
            expect(body_as_json['active']).to eq active
          end

          it 'should modify the ChainTemplate object' do
            updated_template = chain_template.reload
            chain_template_attributes.each do |attribute|
              expect(updated_template.send(attribute)).to eq self.send(attribute)
            end
          end

          it 'should update the chain template with the parameters' do
            expect(user.reload.chain_templates.count).to eq 1

            template = user.chain_templates.first
            expect(template.user).to eq user
            expect(template.name).to eq name
            expect(template.description).to eq description
            expect(template.active).to be_falsey
          end
        end

        context 'if only a subset of attributes are supplied' do
          let!(:original_template)    { chain_template }
          let!(:modified_template_params) {
            {
                chain_template: {
                    name: name,
                    uid: user.email
                },
                id: chain_template.id
            }
          }

          before do
            perform_update_request(auth_headers, chain_template.id, modified_template_params.to_json)
          end

          it 'responds with success' do
            expect(response.status).to eq(200)
          end

          it 'should return the updated ChainTemplate object (with only some changed fields)' do
            expect(body_as_json['name']).to eq name
            expect(body_as_json['description']).to_not eq description
            expect(body_as_json['active']).to_not eq active
          end

          it 'should modify the ChainTemplate object' do
            chain_template.reload
            chain_template_attributes.delete(:name)
            chain_template_attributes.each do |attribute|
              expect(chain_template.send(attribute)).to eq original_template.send(attribute)
            end
            expect(chain_template.name).to eq original_template.name
          end

          it 'should update the chain template with the parameters' do
            expect(user.reload.chain_templates.count).to eq 1

            template = user.chain_templates.first
            expect(template.user).to eq user
            expect(template.name).to eq name
            expect(template.description).to eq original_template.description
            expect(template.active).to eq original_template.active
          end
        end
      end

      context 'and the chain template does not belong to the user' do
        let!(:other_user)     { FactoryGirl.create(:user) }

        before do
          chain_template.update_attribute(:user_id, other_user.id)
          perform_update_request(auth_headers, chain_template.id, chain_template_params.to_json)
        end

        it 'responds with Not Found' do
          expect(response.status).to eq(404)
        end

        it 'should not modify the chain template' do
          original_template = chain_template
          updated_template = chain_template.reload

          chain_template_attributes.each do |facet|
            expect(updated_template.send(facet)).to eq original_template.send(facet)
          end
        end

      end
    end

    context 'if no user is signed in' do
      before do
        perform_update_request({}, chain_template.id, chain_template_params.to_json)
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
        perform_update_request({}, chain_template.id, chain_template_params.to_json)
      end

      it 'should raise an error' do
        expect(response.status).to eq(401)
      end

      it 'should provide a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end

  end
  
  def perform_update_request(auth_headers, id, data)
    update_chain_template_request('v1', auth_headers, id, data)
  end
end