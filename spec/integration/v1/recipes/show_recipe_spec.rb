require 'rails_helper'
require_relative '../version'

describe "Account finds a single recipe" do

  # URL: /api/recipe/:id
  # Method: GET
  # Get a specific recipe belonging to the current account

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: account@example.com, auth_token: asdf" -X GET http://localhost:3000/api/recipes/:id

  describe "GET show recipe" do

    let!(:account)             { create(:account, password: "password", password_confirmation: "password") }
    let!(:auth_headers)     { account.create_new_auth_token }

    let!(:recipe)         { create(:recipe, account: account) }

    context 'if account is signed in' do

      context 'and the recipe exists' do

        context 'and it belongs to the account' do
          it 'responds with success' do
            perform_show_request(auth_headers, recipe.id)

            expect(response.status).to eq(200)
          end

          it 'returns a Recipe object' do
            perform_show_request(auth_headers, recipe.id)

            expect(body_as_json['recipe']['name']).to eq recipe.name
            expect(body_as_json['recipe']['description']).to eq recipe.description
            expect(body_as_json['recipe']['active']).to eq recipe.active
            expect(body_as_json['recipe']['public']).to eq recipe.public
          end

          context 'and it has steps' do
            let!(:step1)      { recipe.recipe_steps.first }
            let!(:step2)      { create(:recipe_step, recipe: recipe, position: 2) }

            it 'also returns the steps' do
              perform_show_request(auth_headers, recipe.id)

              expect(body_as_json['recipe']['recipe_steps'].count).to eq 2
              expect(body_as_json['recipe']['recipe_steps'].sort_by{|s| s['position']}.map{|s| s['step_class_name']}).to match([base_step_class.to_s, conversion_step_class.to_s])
              expect(body_as_json['recipe']['recipe_steps'].sort_by{|s| s['position']}.map{|s| s['description']}).to match([base_step_class.description, conversion_step_class.description])
            end
          end

          context 'and it has process chains' do
            let!(:step1)             { recipe.recipe_steps.first }
            let!(:process_chain)     { create(:process_chain, recipe: recipe, account: account, executed_at: 2.minutes.ago) }
            let!(:process_step)      { create(:executed_process_step_success, process_chain: process_chain) }

            before do
              process_chain.initialize_directories
            end

            it 'also returns the chain information' do
              perform_show_request(auth_headers, recipe.id)
              ap body_as_json

              expect(body_as_json['recipe']['process_chains'].count).to eq 1
              expect(body_as_json['recipe']['process_chains'][0]['process_steps'].count).to eq 1
            end
          end
        end

        context 'and it belongs to a different account' do

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

    context 'if no account is signed in' do
      before do
        perform_show_request({}, recipe.id)
      end

      it 'raises an error' do
        expect(response.status).to eq(401)
      end

      it 'provides a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end

    context 'if the token has expired' do
      before do
        expire_token(account, auth_headers['client'])
        perform_show_request({}, recipe.id)
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