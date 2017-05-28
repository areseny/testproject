require 'rails_helper'
require_relative '../version'

describe "Account archives a single recipe" do

  # URL: /api/recipe/:id
  # Method: DELETE
  # Use this route to archive a recipe so it still exists, but can't be accessed by anyone but an administrator

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: account@example.com, auth_token: asdf" -X GET http://localhost:3000/api/recipes/:id

  describe "GET archive recipe" do

    let!(:account)             { create(:account, password: "password", password_confirmation: "password") }
    let!(:auth_headers)     { account.create_new_auth_token }

    let!(:recipe)         { create(:recipe, account: account) }

    context 'if account is signed in' do

      context 'and the recipe exists' do

        before do
          perform_archive_request(auth_headers, recipe.id)
        end

        context 'and it belongs to the account' do
          it 'responds with success' do
            expect(response.status).to eq(200)
          end

          it 'returns a Recipe object' do
            expect(body_as_json['recipe']['name']).to eq recipe.name
            expect(body_as_json['recipe']['description']).to eq recipe.description
            expect(body_as_json['recipe']['active']).to eq recipe.active
          end
        end

        context 'and it belongs to a different account' do
          let!(:other_account)     { create(:account) }

          before do
            recipe.update_attribute(:account_id, other_account.id)
          end

          it 'responds with failure' do
            perform_archive_request(auth_headers, recipe.id)
            expect(response.status).to eq(404)
          end
        end
      end

      context 'and the recipe does not exist' do

        before do
          recipe.destroy
          perform_archive_request(auth_headers, "rubbish")
        end

        it 'responds with failure' do
          expect(response.status).to eq(404)
        end
      end
    end

    context 'if no account is signed in' do
      before do
        perform_archive_request({}, recipe.id)
      end

      it 'raises an error' do
        expect(response.status).to eq(401)
      end

      it 'provides a message' do
        expect_to_contain_string(body_as_json['errors'], /You need to sign in or sign up before continuing/)
      end
    end

    context 'if the token has expired' do
      before do
        expire_token(account, auth_headers['client'])
        perform_archive_request({}, recipe.id)
      end

      it 'raises an error' do
        expect(response.status).to eq(401)
      end

      it 'provides a message' do
        expect_to_contain_string(body_as_json['errors'], /You need to sign in or sign up before continuing./)
      end
    end

  end
  
  def perform_archive_request(auth_headers, id)
    archive_recipe_request(version, auth_headers, id)
  end
end