require 'rails_helper'
require_relative '../version'

describe "Account updates recipe" do

  # URL: /api/recipes/:id/
  # Method: PUT or PATCH
  # Update the details of a recipe.

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: account@example.com, auth_token: asdf" -X PUT http://localhost:3000/api/recipes/:id

  describe "PUT update recipe" do

    let!(:account)          { create(:account, password: "password", password_confirmation: "password") }
    let!(:name)             { "My Splendiferous HTML to PDF transmogrifier" }
    let!(:description)      { "It transmogrifies! It transforms! It even goes across filetypes!" }
    let!(:active)           { false }
    let!(:public)           { true }
    let!(:auth_headers)     { account.new_jwt }
    let!(:recipe)           { create(:recipe, account: account) }

    let!(:recipe_params) {
      {
          recipe: {
              name: name,
              description: description,
              uid: account.email,
              active: active,
              public: public
          },
          id: recipe.id
      }
    }

    let!(:recipe_attributes){ [:name, :description, :active, :public]  }

    context 'if account is signed in' do

      context 'and the recipe belongs to the account' do

        context 'if all attributes are supplied' do
          before do
            perform_update_request(auth_headers, recipe_params)
          end

          it 'responds with success' do
            expect(response.status).to eq(200)
          end

          it 'returns the updated Recipe object' do
            expect(body_as_json['recipe']['name']).to eq name
            expect(body_as_json['recipe']['description']).to eq description
            expect(body_as_json['recipe']['active']).to eq active
            expect(body_as_json['recipe']['public']).to eq public
          end

          it 'modifies the Recipe object' do
            updated_recipe = recipe.reload
            recipe_attributes.each do |attribute|
              expect(updated_recipe.send(attribute)).to eq self.send(attribute)
            end
          end

          it 'updates the recipe with the parameters' do
            expect(account.reload.recipes.count).to eq 1

            recipe = account.recipes.first
            expect(recipe.account).to eq account
            expect(recipe.name).to eq name
            expect(recipe.description).to eq description
            expect(recipe.active).to be_falsey
            expect(recipe.public).to be_truthy
          end
        end

        context 'if only a subset of attributes are supplied' do
          let!(:original_recipe)    { recipe }
          let!(:modified_recipe_params) {
            {
                recipe: {
                    name: name,
                    uid: account.email
                },
                id: recipe.id
            }
          }

          before do
            perform_update_request(auth_headers, modified_recipe_params)
          end

          it 'responds with success' do
            expect(response.status).to eq(200)
          end

          it 'returns the updated Recipe object (with only some changed fields)' do
            expect(body_as_json['recipe']['name']).to eq name
            expect(body_as_json['recipe']['description']).to_not eq description
            expect(body_as_json['recipe']['active']).to_not eq active
            expect(body_as_json['recipe']['public']).to_not eq public
          end

          it 'modifies the Recipe object' do
            recipe.reload
            recipe_attributes.delete(:name)
            recipe_attributes.each do |attribute|
              expect(recipe.send(attribute)).to eq original_recipe.send(attribute)
            end
            expect(recipe.name).to eq original_recipe.name
          end

          it 'updates the recipe with the parameters' do
            expect(account.reload.recipes.count).to eq 1

            recipe = account.recipes.first
            expect(recipe.account).to eq account
            expect(recipe.name).to eq name
            expect(recipe.public).to eq original_recipe.public
            expect(recipe.description).to eq original_recipe.description
            expect(recipe.active).to eq original_recipe.active
          end
        end
      end

      context 'and the recipe does not belong to the account' do
        let!(:other_account)     { create(:account) }

        before do
          recipe.update_attribute(:account_id, other_account.id)
          perform_update_request(auth_headers, recipe_params)
        end

        it 'responds with Not Found' do
          expect(response.status).to eq(404)
        end

        it 'does not modify the recipe' do
          original_recipe = recipe
          updated_recipe = recipe.reload

          recipe_attributes.each do |facet|
            expect(updated_recipe.send(facet)).to eq original_recipe.send(facet)
          end
        end

      end
    end

    context 'if no account is signed in' do
      before do
        perform_update_request({}, recipe_params)
      end

      it 'raises an error' do
        expect(response.status).to eq(401)
      end

      it 'provides a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end

    xcontext 'if the token has expired' do
      before do
        expire_token(account, auth_headers['client'])
        perform_update_request({}, recipe_params)
      end

      it 'raises an error' do
        expect(response.status).to eq(401)
      end

      it 'provides a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end

  end
  
  def perform_update_request(auth_headers, data)
    update_recipe_request(version, auth_headers, data)
  end
end