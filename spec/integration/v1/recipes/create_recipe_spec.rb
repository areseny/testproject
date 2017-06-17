require 'rails_helper'
require_relative '../version'

describe "Account creates recipe" do

  # URL: /api/recipes
  # Method: POST
  # Use this route to create a recipe.

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: account@example.com, auth_token: asdf" -X POST http://localhost:3000/api/recipes

  describe "POST create new recipe" do

    let!(:account)          { create(:account, password: "password", password_confirmation: "password") }
    let!(:name)             { "My Splendiferous PNG to JPG transmogrifier" }
    let!(:description)      { "It transmogrifies! It transforms! It even goes across filetypes!" }
    let!(:auth_headers)     { account.new_jwt }
    let(:public)            { true }

    let!(:recipe_params) {
      {
          recipe: {
              name: name,
              description: description,
              uid: account.email,
              public: public
          }
      }
    }

    context 'if account is signed in' do

      context 'and the account provides no step data' do
        before do
          perform_create_request(auth_headers, recipe_params)
        end

        it 'responds with success' do
          expect(response.status).to eq(422)
          expect(body_as_json['errors']).to eq ["Validation failed: Recipe steps - Please add at least one recipe step"]
        end
      end

      context 'if there are steps supplied' do

        let(:generic_step)      { base_step_class.to_s }
        let(:rot13)             { rot_thirteen_step_class.to_s }

        context 'presented as a series of steps with positions included' do
          let(:step_params)      { [{position: 1, step_class_name: generic_step}, {position: 2, step_class_name: rot13 }] }

          context 'and they are valid' do
            before do
              recipe_params[:recipe][:steps_with_positions] = step_params
              perform_create_request(account.new_jwt, recipe_params)
            end

            it "creates the recipe with recipe steps" do
              expect(response.status).to eq 200
              new_recipe = account.recipes.first
              expect(new_recipe.recipe_steps.count).to eq 2
              expect(new_recipe.recipe_steps.sort_by(&:position).map(&:step_class_name)).to eq [generic_step, rot13]
            end

            it 'returns a Recipe object' do
              expect(body_as_json['recipe']['name']).to eq name
              expect(body_as_json['recipe']['description']).to eq description
              expect(body_as_json['recipe']['active']).to be_truthy
              expect(body_as_json['recipe']['public']).to be_truthy
            end

            it 'creates a new recipe with the parameters' do
              expect(account.reload.recipes.count).to eq 1

              recipe = account.recipes.first
              expect(recipe.account).to eq account
              expect(recipe.name).to eq name
              expect(recipe.description).to eq description
              expect(recipe.active).to be_truthy
              expect(recipe.public).to be_truthy
            end
          end

          context 'and they are incorrect' do

            it "does not create the recipe for nonexistent step classes" do
              recipe_params[:recipe][:steps_with_positions] = [{position: 1, step_class_name: "rubbish"}, {position: 1, step_class_name: rot13 }]
              perform_create_request(account.new_jwt, recipe_params.to_json)

              expect(response.status).to eq 422
            end

            it "does not create the recipe with duplicate numbers" do
              recipe_params[:recipe][:steps_with_positions] = [{position: 1, step_class_name: generic_step}, {position: 1, step_class_name: rot13 }]
              perform_create_request(account.new_jwt, recipe_params)

              expect(response.status).to eq 422
            end

            it "does not create the recipe with incorrect numbers" do
              recipe_params[:recipe][:steps_with_positions] = [{position: 0, step_class_name: generic_step}, {position: 1, step_class_name: rot13 }]
              perform_create_request(account.new_jwt, recipe_params)

              expect(response.status).to eq 422
            end

            it "does not create the recipe with skipped steps" do
              recipe_params[:recipe][:steps_with_positions] = [{position: 1, step_class_name: generic_step}, {position: 6, step_class_name: rot13 }]
              perform_create_request(account.new_jwt, recipe_params)

              expect(response.status).to eq 422
            end

            it "does create the recipe with numbers out of order" do
              recipe_params[:recipe][:steps_with_positions] = [{position: 2, step_class_name: rot13 }, {position: 1, step_class_name: generic_step}]
              perform_create_request(account.new_jwt, recipe_params)

              expect(response.status).to eq 200
              new_recipe = account.recipes.first
              expect(new_recipe.recipe_steps.count).to eq 2
              expect(new_recipe.recipe_steps.sort_by(&:position).map(&:step_class_name)).to eq [generic_step, rot13]
            end
          end
        end

        context 'presented as a series of steps with order implicit' do
          context 'and they are real steps' do
            before do
              recipe_params[:recipe][:steps] = [base_step_class.to_s, rot_thirteen_step_class.to_s]
            end

            it "creates the recipe with recipe steps" do
              perform_create_request(account.new_jwt, recipe_params)

              expect(response.status).to eq 200
              new_recipe = account.recipes.first
              expect(new_recipe.recipe_steps.count).to eq 2
              expect(new_recipe.recipe_steps.sort_by(&:position).map(&:step_class_name)).to eq [generic_step, rot13]
            end
          end

          context 'and they are not real' do

            it "creates the recipe for nonexistent step classes anyway" do
              recipe_params[:recipe][:steps] = ["NonexistentClass", rot_thirteen_step_class.to_s]
              perform_create_request(account.new_jwt, recipe_params)

              expect(response.status).to eq 200
            end
          end
        end
      end


    end

    context 'if no account is signed in' do
      before do
        perform_create_request({}, recipe_params)
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
        perform_create_request({}, recipe_params)
      end

      it 'raises an error' do
        expect(response.status).to eq(401)
      end

      it 'provides a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end

  end
  
  def perform_create_request(auth_headers, data)
    create_recipe_request(version, auth_headers, data.to_json)
  end
end