require 'rails_helper'
require_relative '../version'

describe "User finds a single recipe" do

  # URL: /api/recipe/:id
  # Method: GET
  # Get a specific recipe belonging to the current user

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X GET http://localhost:3000/api/recipes/:id

  describe "GET show recipe" do

    let!(:user)             { FactoryGirl.create(:user, password: "password", password_confirmation: "password") }
    let!(:auth_headers)     { user.create_new_auth_token }

    let!(:recipe)         { FactoryGirl.create(:recipe, user: user) }

    context 'if user is signed in' do

      context 'and the recipe exists' do

        context 'and it belongs to the user' do
          it 'responds with success' do
            perform_show_request(auth_headers, recipe.id)

            expect(response.status).to eq(200)
          end

          it 'should return a Recipe object' do
            perform_show_request(auth_headers, recipe.id)

            expect(body_as_json['name']).to eq recipe.name
            expect(body_as_json['description']).to eq recipe.description
            expect(body_as_json['active']).to eq recipe.active
          end

          context 'and it has steps' do
            let!(:step1)      { FactoryGirl.create(:recipe_step, recipe: recipe, position: 1) }
            let!(:step2)      { FactoryGirl.create(:recipe_step, recipe: recipe, position: 2) }

            it 'should also return the steps' do
              perform_show_request(auth_headers, recipe.id)

              expect(body_as_json['recipe_steps'].count).to eq 2
            end
          end
        end

        context 'and it belongs to a different user' do

          let!(:other_user)     { FactoryGirl.create(:user) }

          before do
            recipe.update_attribute(:user_id, other_user.id)
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

    context 'if no user is signed in' do
      before do
        perform_show_request({}, recipe.id)
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
        perform_show_request({}, recipe.id)
      end

      it 'should raise an error' do
        expect(response.status).to eq(401)
      end

      it 'should provide a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end

  end
  
  def perform_show_request(auth_headers, id)
    show_recipe_request(version, auth_headers, id)
  end
end