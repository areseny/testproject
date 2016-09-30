require 'rails_helper'
require_relative '../version'

describe "User archives a single recipe" do

  # URL: /api/recipe/:id
  # Method: DELETE
  # Use this route to archive a recipe so it still exists, but can't be accessed by anyone but an administrator

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X GET http://localhost:3000/api/recipes/:id

  describe "GET archive recipe" do

    let!(:user)             { create(:user, password: "password", password_confirmation: "password") }
    let!(:auth_headers)     { user.create_new_auth_token }

    let!(:recipe)         { create(:recipe, user: user) }

    context 'if user is signed in' do

      context 'and the recipe exists' do

        before do
          perform_archive_request(auth_headers, recipe.id)
        end

        context 'and it belongs to the user' do
          it 'responds with success' do
            expect(response.status).to eq(200)
          end

          it 'should return a Recipe object' do
            expect(body_as_json['name']).to eq recipe.name
            expect(body_as_json['description']).to eq recipe.description
            expect(body_as_json['active']).to eq recipe.active
          end
        end

        context 'and it belongs to a different user' do
          let!(:other_user)     { create(:user) }

          before do
            recipe.update_attribute(:user_id, other_user.id)
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

    context 'if no user is signed in' do
      before do
        perform_archive_request({}, recipe.id)
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
        perform_archive_request({}, recipe.id)
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
    archive_recipe_request(version, auth_headers, id)
  end
end