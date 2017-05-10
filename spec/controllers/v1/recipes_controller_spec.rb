require 'rails_helper'
require_relative 'version'

RSpec.describe Api::V1::RecipesController do

  let!(:account)           { create(:account) }
  let!(:other_account)     { create(:account) }

  let!(:name)           { "My Splendiferous PNG to JPG transmogrifier" }
  let!(:description)    { "It transmogrifies! It transforms! It even goes across filetypes!" }

  let!(:step)           { base_step_class.to_s }
  let!(:rot_thirteen)   { rot_thirteen_step_class.to_s }

  let!(:attributes)     { [:name, :description] }

  let!(:recipe_params) {
    {
        recipe: {
            name: name,
            description: description,
            public: true
        }
    }
  }

  describe "POST execute" do

    let(:demo_step)         { base_step_class.to_s }
    let(:xml_file)          { fixture_file_upload('files/test_file.xml', 'text/xml') }
    let(:photo_file)        { fixture_file_upload('files/kitty.jpeg', 'image/jpeg') }
    let(:recipe)            { create(:recipe, account: account) }
    let(:recipe_step)       { recipe.recipe_steps.first }

    let(:execution_params) {
        {
            id: recipe.id,
            input_files: photo_file
        }
    }

    context 'if a valid token is supplied' do
      context 'if a file is supplied' do
        context 'if the recipe is public' do
          before do
            recipe.update_attribute(:public, true)
          end

          context 'if the recipe belongs to that account' do
            before do
              recipe.update_attribute(:account_id, account.id)
            end

            it 'tries to execute the process chain' do
              request_with_auth(account.new_jwt) do
                perform_execute_request(execution_params)
              end

              expect(response.status).to eq 200
              expect(assigns(:new_chain)).to_not be_nil
            end
          end

          context 'if the recipe belongs to a different account' do
            before do
              recipe.update_attribute(:account_id, other_account.id)
            end

            it 'tries to execute the process chain' do
              request_with_auth(account.new_jwt) do
                perform_execute_request(execution_params)
              end

              expect(response.status).to eq 200
              expect(assigns(:new_chain)).to_not be_nil
            end
          end

          context 'if one of the steps does not exist' do
            before do
              recipe_step.update_attribute(:step_class_name, "NonexistentStep")
            end

            it 'fails' do
              request_with_auth(account.new_jwt) do
                perform_execute_request(execution_params)
              end

              expect(response.status).to eq 422
              expect(assigns(:new_chain)).to be_nil
            end
          end
        end

        context 'if the recipe is not public' do
          before do
            recipe.update_attribute(:public, false)
          end

          context 'if the recipe belongs to that account' do
            it 'tries to execute the process chain' do
              request_with_auth(account.new_jwt) do
                perform_execute_request(execution_params)
              end

              expect(response.status).to eq 200
              expect(assigns(:new_chain)).to_not be_nil
            end
          end

          context 'if the recipe belongs to a different account' do
            before do
              recipe.update_attribute(:account_id, other_account.id)
            end

            it 'fails' do
              request_with_auth(account.new_jwt) do
                perform_execute_request(execution_params)
              end

              expect(response.status).to eq 404
              expect(assigns(:new_chain)).to be_nil
            end
          end
        end
      end

      context 'if no file is supplied' do
        before do
          execution_params.delete(:input_files)
        end

        it 'fails' do
          request_with_auth(account.new_jwt) do
            perform_execute_request(execution_params)
          end

          expect(response.status).to eq 422
          expect(assigns(:new_chain)).to be_nil
        end
      end
    end

    context 'if no valid token is supplied' do

      it "does not assign anything" do
        request_with_auth do
          perform_execute_request(execution_params)
        end

        expect(response.status).to eq 401
      end
    end
  end

  describe "POST update" do
    let!(:new_name)         { "fabulous recipe" }
    let!(:new_description)  { "absolutely magical" }
    let(:recipe_params) {
        {
          recipe: {
          name: new_name,
          description: new_description,
          public: false
        },
          id: recipe.id
      }
    }
    let(:recipe)            { create(:recipe, account: account, public: true) }

    it 'updates the values' do
      request_with_auth(account.new_jwt) do
        perform_update_request(recipe_params)
      end

      recipe.reload

      expect(response.status).to eq 200
      expect(recipe.name).to eq new_name
      expect(recipe.description).to eq new_description
      expect(recipe.public).to eq false
    end
  end

  describe "POST create" do

    context 'if a valid token is supplied' do
      context 'if the recipe is valid' do
        context 'presented as a series of steps with positions included' do
          let!(:step_params)      { [{position: 1, step_class_name: step }, {position: 2, step_class_name: rot_thirteen }] }

          context 'and they are valid' do
            before do
              recipe_params[:recipe][:steps_with_positions] = step_params
            end

            it "creates the recipe with recipe steps" do
              request_with_auth(account.new_jwt) do
                perform_create_request(recipe_params)
              end

              expect(response.status).to eq 200
              new_recipe = assigns[:new_recipe]
              expect(new_recipe).to be_a Recipe
              attributes.each do |attribute|
                expect(new_recipe.send(attribute)).to eq self.send(attribute)
              end
              expect(new_recipe.recipe_steps.count).to eq 2
              expect(new_recipe.recipe_steps.sort_by(&:position).map(&:step_class_name)).to eq [step, rot_thirteen]
            end

            it "creates the recipe for nonexistent step classes" do
              recipe_params[:recipe][:steps_with_positions] = [{position: 1, step_class_name: "NonexistentStep"}, {position: 2, step_class_name: rot_thirteen }]

              request_with_auth(account.new_jwt) do
                perform_create_request(recipe_params)
              end

              expect(response.status).to eq 200
            end
          end

          context 'and they are incorrect' do
            it "does not create the recipe with duplicate numbers" do
              recipe_params[:recipe][:steps_with_positions] = [{position: 1, step_class_name: step}, {position: 1, step_class_name: rot_thirteen }]

              request_with_auth(account.new_jwt) do
                perform_create_request(recipe_params)
              end

              expect(response.status).to eq 422
            end

            it "does not create the recipe with incorrect numbers" do
              recipe_params[:recipe][:steps_with_positions] = [{position: 0, step_class_name: step}, {position: 1, step_class_name: rot_thirteen }]

              request_with_auth(account.new_jwt) do
                perform_create_request(recipe_params)
              end

              expect(response.status).to eq 422
            end

            it "does not create the recipe with skipped steps" do
              recipe_params[:recipe][:steps_with_positions] = [{position: 1, step_class_name: step}, {position: 6, step_class_name: rot_thirteen }]

              request_with_auth(account.new_jwt) do
                perform_create_request(recipe_params)
              end

              expect(response.status).to eq 422
            end

            it "creates the recipe with nonsequential numbers" do
              recipe_params[:recipe][:steps_with_positions] = [{position: 2, step_class_name: step }, {position: 1, step_class_name: rot_thirteen}]

              request_with_auth(account.new_jwt) do
                perform_create_request(recipe_params)
              end

              expect(response.status).to eq 200
              new_recipe = assigns[:new_recipe]
              expect(new_recipe).to be_a Recipe
              attributes.each do |attribute|
                expect(new_recipe.send(attribute)).to eq self.send(attribute)
              end
              expect(new_recipe.recipe_steps.count).to eq 2
            end
          end
        end

        context 'presented as a series of steps with order implicit' do
          context 'and they are valid' do
            before do
              recipe_params[:recipe][:steps] = [step, rot_thirteen]
            end

            it "creates the recipe with recipe steps" do
              request_with_auth(account.new_jwt) do
                perform_create_request(recipe_params)
              end

              expect(response.status).to eq 200
              new_recipe = assigns[:new_recipe]
              expect(new_recipe).to be_a Recipe
              attributes.each do |attribute|
                expect(new_recipe.send(attribute)).to eq self.send(attribute)
              end
              expect(new_recipe.recipe_steps.count).to eq 2
              expect(new_recipe.recipe_steps.sort_by(&:position).map(&:step_class_name)).to eq [step, rot_thirteen]
            end

            it "creates the recipe for nonexistent step classes" do
              recipe_params[:recipe][:steps] = ["NonexistentStep", rot_thirteen]

              request_with_auth(account.new_jwt) do
                perform_create_request(recipe_params)
              end

              expect(response.status).to eq 200
            end

            context 'if the recipe is flagged private' do
              let(:recipe_params) {
                {
                    recipe: {
                        name: name,
                        description: description,
                        public: false,
                        steps: [step]
                    }
                }
              }

              specify do
                request_with_auth(account.new_jwt) do
                  perform_create_request(recipe_params)
                end

                expect(response.status).to eq 200
                new_recipe = assigns[:new_recipe]
                expect(new_recipe.public).to eq false
              end
            end

            context 'if the recipe is flagged public' do
              let(:recipe_params) {
                {
                    recipe: {
                        name: name,
                        description: description,
                        public: true,
                        steps: [step]
                    }
                }
              }

              specify do
                request_with_auth(account.new_jwt) do
                  perform_create_request(recipe_params)
                end

                expect(response.status).to eq 200
                new_recipe = assigns[:new_recipe]
                expect(new_recipe.public).to eq true
              end
            end
          end
        end
      end

      context 'if the recipe is invalid' do

        context 'if there are no steps supplied' do
          it "assigns" do
            request_with_auth(account.new_jwt) do
              perform_create_request(recipe_params)
            end

            expect(response.status).to eq 422
            expect(body_as_json['errors']).to eq ["Validation failed: Recipe steps - Please add at least one recipe step"]
          end
        end

        context 'if the recipe is missing a field' do
          before do
            recipe_params[:recipe].delete(:name)
            recipe_params[:recipe][:steps] = [step]
          end

          it "is not successful" do
            request_with_auth(account.new_jwt) do
              perform_create_request(recipe_params)
            end

            expect(response.status).to eq 422
            expect(body_as_json['errors']).to eq ["Validation failed: Name can't be blank"]
          end
        end
      end
    end

    context 'if no valid token is supplied' do

      it "does not assign anything" do
        request_with_auth do
          perform_create_request(recipe_params)
        end

        expect(response.status).to eq 401
        expect(assigns[:new_recipe]).to be_nil
      end
    end
  end

  describe "PUT update" do

    let!(:recipe)   { create(:recipe, account: account) }

    context 'if a valid token is supplied' do

      it "assigns" do
        request_with_auth(account.new_jwt) do
          perform_update_request(recipe_params.merge(id: recipe.id))
        end

        expect(response.status).to eq 200
        recipe = assigns[:recipe]
        expect(recipe).to be_a Recipe
        attributes.each do |facet|
          expect(recipe.send(facet)).to eq self.send(facet)
        end
      end
    end

    context 'if no valid token is supplied' do

      it "does not assign anything" do
        request_with_auth do
          perform_update_request(recipe_params.merge(id: recipe.id))
        end

        expect(response.status).to eq 401
        expect(assigns[:new_recipe]).to be_nil
      end
    end
  end

  describe "GET index" do

    context 'if a valid token is supplied' do

      context 'there are no recipes' do

        it "finds no recipes" do
          request_with_auth(account.new_jwt) do
            perform_index_request
          end

          expect(response.status).to eq 200
          expect(assigns[:recipes]).to eq []
        end

      end

      context 'there are recipes' do
        let!(:other_account)    { create(:account) }
        let!(:recipe_1)      { create(:recipe, name: "recipe1", account: account) }
        let!(:recipe_2)      { create(:recipe, name: "recipe2", account: account, active: false) }
        let!(:recipe_3)      { create(:recipe, name: "recipe3", account: other_account) }
        let!(:chain1)        { create(:process_chain, recipe: recipe_3, account: other_account) }
        let!(:recipe_4)      { create(:recipe, name: "recipe4", account: account, public: false) }
        let!(:chain2)        { create(:process_chain, recipe: recipe_4, account: other_account) }

        it "finds the account's recipes" do
          request_with_auth(account.new_jwt) do
            perform_index_request
          end

          expect(response.status).to eq 200
          expect(assigns[:recipes].to_a).to eq [recipe_1, recipe_4]
        end
      end
    end

    context 'if no valid token is supplied' do

      it "does not assign anything" do
        request_with_auth do
          perform_index_request({})
        end

        expect(response.status).to eq 401
        expect(assigns[:recipe]).to be_nil
      end
    end
  end

  describe "GET show" do

    context 'if a valid token is supplied' do

      context 'if the recipe does not exist' do

        it "returns an error" do
          request_with_auth(account.new_jwt) do
            perform_show_request({id: "nonsense"})
          end

          expect(response.status).to eq 404
          expect(assigns[:recipe]).to be_nil
        end

      end

      context 'the recipe exists' do

        context 'the recipe belongs to the account' do
          let!(:recipe)      { create(:recipe, account: account) }

          it "finds the recipe" do
            request_with_auth(account.new_jwt) do
              perform_show_request({id: recipe.id})
            end

            expect(response.status).to eq 200
            expect(assigns[:recipe]).to eq recipe
          end

          context 'and it has process chains' do
            let!(:process_chain)       { create(:process_chain, recipe: recipe, executed_at: 2.minutes.ago) }
            let!(:process_step)        { create(:executed_process_step_success, process_chain: process_chain) }

            before { recipe.reload }

            it "finds the recipe" do
              request_with_auth(account.new_jwt) do
                perform_show_request({id: recipe.id})
              end

              expect(response.status).to eq 200
              expect(assigns[:recipe]).to eq recipe
            end
          end
        end

        context 'the recipe belongs to another account' do
          let!(:other_account)     { create(:account) }
          let!(:recipe)       { create(:recipe, account: other_account) }

          it "does not find the recipe" do
            request_with_auth(account.new_jwt) do
              perform_show_request({id: recipe.id})
            end

            expect(response.status).to eq 404
            expect(assigns[:recipe]).to be_nil
          end
        end
      end
    end

    context 'if no valid token is supplied' do

      it "does not return anything" do
        request_with_auth do
          perform_show_request({id: "rubbish"})
        end

        expect(response.status).to eq 401
        expect(assigns[:recipe]).to be_nil
      end
    end
  end

  describe "DELETE destroy" do

    context 'if a valid token is supplied' do

      context 'if the recipe does not exist' do

        it "returns an error" do
          request_with_auth(account.new_jwt) do
            perform_destroy_request({id: "nonsense"})
          end

          expect(response.status).to eq 404
          expect(assigns[:recipe]).to be_nil
        end

      end

      context 'the recipe exists' do

        context 'the recipe belongs to the account' do
          let!(:recipe)      { create(:recipe, account: account) }

          it "finds the recipe" do
            request_with_auth(account.new_jwt) do
              perform_destroy_request({id: recipe.id})
            end

            expect(response.status).to eq 200
            expect(assigns[:recipe]).to eq recipe
          end
        end

        context 'the recipe belongs to another account' do
          let!(:other_account)     { create(:account) }
          let!(:recipe)       { create(:recipe, account: other_account) }

          it "does not find the recipe" do
            request_with_auth(account.new_jwt) do
              perform_destroy_request({id: recipe.id})
            end

            expect(response.status).to eq 404
            expect(assigns[:recipe]).to be_nil
          end
        end
      end
    end

    context 'if no valid token is supplied' do

      it "does not return anything" do
        request_with_auth do
          perform_destroy_request({id: "rubbish"})
        end

        expect(response.status).to eq 401
        expect(assigns[:recipe]).to be_nil
      end
    end
  end

  # request.headers.merge!(auth_headers)
  # this is special for controller tests - you can't just merge them in manually for some reason

  def perform_execute_request(data = {})
    execute_recipe(version, data)
  end

  def perform_create_request(data = {})
    post_create_request(version, data)
  end

  def perform_update_request(data)
    put_update_request(version, data)
  end

  def perform_index_request(data = {})
    get_index_request(version, data)
  end

  def perform_show_request(data = {})
    get_show_request(version, data)
  end

  def perform_destroy_request(data = {})
    delete_destroy_request(version, data)
  end
end