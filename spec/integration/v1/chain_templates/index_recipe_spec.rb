require 'rails_helper'
require_relative '../version'

describe "User lists all their recipes" do

  # URL: /api/recipes/
  # Method: GET
  # Get all the recipes belonging to the current user

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X GET http://localhost:3000/api/recipes

  describe "GET index recipe" do

    let!(:user)               { FactoryGirl.create(:user, password: "password", password_confirmation: "password") }
    let!(:other_user)         { FactoryGirl.create(:user) }

    let!(:auth_headers)       { user.create_new_auth_token }
    let!(:recipe)           { FactoryGirl.create(:recipe, user: user) }
    let!(:inactive_recipe)  { FactoryGirl.create(:recipe, user: user, active: false) }
    let!(:other_recipe)     { FactoryGirl.create(:recipe, user: other_user) }

    context 'if user is signed in' do

      context 'and there are some active recipes that belong to the user' do

        before do
          perform_index_request(auth_headers)
        end

        it 'responds with success' do
          expect(response.status).to eq(200)
        end

        it 'should return a list of Recipe objects' do
          expect(body_as_json.count).to eq 1

          expect(body_as_json[0]['name']).to eq recipe.name
          expect(body_as_json[0]['description']).to eq recipe.description
          expect(body_as_json[0]['user_id']).to eq recipe.user.id
          expect(body_as_json[0]['active']).to eq recipe.active
        end
      end

      context 'and there are no active recipes that belong to the current user' do

        before do
          recipe.destroy
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
    index_recipe_request(version, auth_headers)
  end
end