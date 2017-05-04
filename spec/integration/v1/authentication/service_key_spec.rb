require 'rails_helper'
require_relative '../version'

describe "Service finds a single recipe via service auth key" do

  # URL: /api/recipe/:id
  # Method: GET
  # Get a specific recipe belonging to the current account

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: account@example.com, service_key: LET_ME_IN" -X GET http://localhost:3000/api/recipes/:id

  describe "GET show recipe" do

    let!(:account)          { create(:account) }
    let!(:service)          { create(:service, account: account) }
    let!(:recipe)           { create(:recipe, account: account) }
    let(:auth_headers)      { {uid: account.email, service_key: service.auth_key} }

    context 'the service key is valid' do
      context 'the recipe is accessible to the service' do
        it 'responds with success' do
          perform_show_request(auth_headers, recipe.id)

          expect(response.status).to eq(200)
        end

        context 'the recipe is not accessible to the service' do
          let!(:other_account)     { create(:account) }

          before do
            recipe.update_attribute(:account_id, other_account.id)
          end

          it 'responds with failure' do
            perform_show_request(auth_headers, recipe.id)
            expect(response.status).to eq(404)
          end
        end
      end

      context 'and the recipe does not exist' do

        before do
          recipe.destroy
          perform_show_request(auth_headers, "rubbish")
        end

        it 'responds with failure' do
          expect(response.status).to eq(404)
        end
      end
    end

    context 'if no auth key is supplied' do
      let(:invalid_auth_headers)      { {uid: account.email, service_key: nil} }
      before do
        perform_show_request(invalid_auth_headers, recipe.id)
      end

      it 'raises an error' do
        expect(response.status).to eq(401)
      end

      it 'provides a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end

    context 'if the key is not valid' do
      let(:invalid_auth_headers)      { {uid: account.email, service_key: "RUBBISH"} }

      before do
        perform_show_request(invalid_auth_headers, recipe.id)
      end

      it 'raises an error' do
        expect(response.status).to eq(401)
      end

      it 'provides a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end

  end
  
  def perform_show_request(auth_headers, id)
    show_recipe_request(version, auth_headers, id)
  end
end