require_relative 'version'

RSpec.describe Api::V1::RecipesController do
  include Devise::Test::ControllerHelpers

  let!(:user)           { create(:user) }
  let!(:other_user)     { create(:user) }

  let!(:name)           { "My Splendiferous PNG to JPG transmogrifier" }
  let!(:description)    { "It transmogrifies! It transforms! It even goes across filetypes!" }

  let!(:step)           { "InkStep::BasicStep" }
  let!(:rot_thirteen)   { "RotThirteenStep" }

  let!(:attributes)     { [:name, :description] }

  let!(:recipe_params) {
    {
        recipe: {
            name: name,
            description: description
        }
    }
  }

  describe "POST execute" do

    let(:demo_step)         { "InkStep::BasicStep" }
    let(:xml_file)          { fixture_file_upload('files/test_file.xml', 'text/xml') }
    let(:photo_file)        { fixture_file_upload('files/kitty.jpeg', 'image/jpeg') }
    let(:recipe_step)       { create(:recipe_step, step_class_name: demo_step) }
    let(:recipe)            { create(:recipe, user: user, recipe_steps: [recipe_step]) }

    let(:execution_params) {
        {
            id: recipe.id,
            input_file: photo_file
        }
    }

    context 'if a valid token is supplied' do
      context 'if a file is supplied' do
        context 'if the recipe is public' do
          before do
            recipe.update_attribute(:public, true)
          end

          context 'if the recipe belongs to that user' do
            before do
              recipe.update_attribute(:user_id, user.id)
            end

            it 'should try to execute the conversion chain' do
              request_with_auth(user.create_new_auth_token) do
                perform_execute_request(execution_params)
              end

              expect(response.status).to eq 200
              expect(assigns(:new_chain)).to_not be_nil
            end
          end

          context 'if the recipe belongs to a different user' do
            before do
              recipe.update_attribute(:user_id, other_user.id)
            end

            it 'should try to execute the conversion chain' do
              request_with_auth(user.create_new_auth_token) do
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

            it 'should fail' do
              request_with_auth(user.create_new_auth_token) do
                perform_execute_request(execution_params)
              end

              expect(response.status).to eq 422
              expect(assigns(:new_chain)).to be_nil
              ap body_as_json
            end
          end
        end

        context 'if the recipe is not public' do
          before do
            recipe.update_attribute(:public, false)
          end

          context 'if the recipe belongs to that user' do
            it 'should try to execute the conversion chain' do
              request_with_auth(user.create_new_auth_token) do
                perform_execute_request(execution_params)
              end

              expect(response.status).to eq 200
              expect(assigns(:new_chain)).to_not be_nil
            end
          end

          context 'if the recipe belongs to a different user' do
            before do
              recipe.update_attribute(:user_id, other_user.id)
            end

            it 'should fail' do
              request_with_auth(user.create_new_auth_token) do
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
          execution_params.delete(:input_file)
        end

        it 'should fail' do
          request_with_auth(user.create_new_auth_token) do
            perform_execute_request(execution_params)
          end

          expect(response.status).to eq 422
          expect(assigns(:new_chain)).to be_nil
        end
      end
    end

    context 'if no valid token is supplied' do

      it "should not assign anything" do
        request_with_auth do
          perform_execute_request(execution_params)
        end

        expect(response.status).to eq 401
      end
    end
  end

  describe "POST create" do

    context 'if a valid token is supplied' do

      context 'if the recipe is valid' do
        it "should assign" do
          request_with_auth(user.create_new_auth_token) do
            perform_create_request(recipe_params)
          end

          expect(response.status).to eq 200
          new_recipe = assigns[:new_recipe]
          expect(new_recipe).to be_a Recipe
          attributes.each do |attribute|
            expect(new_recipe.send(attribute)).to eq self.send(attribute)
          end
        end

        context 'if there are steps supplied' do

          context 'presented as a series of steps with positions included' do
            let!(:step_params)      { [{position: 1, step_class_name: step }, {position: 2, step_class_name: rot_thirteen }] }

            context 'and they are valid' do
              before do
                recipe_params[:steps_with_positions] = step_params
              end

              it "should create the recipe with recipe steps" do
                request_with_auth(user.create_new_auth_token) do
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

              it "should create the recipe for nonexistent step classes" do
                recipe_params[:steps_with_positions] = [{position: 1, step_class_name: "NonexistentStep"}, {position: 2, step_class_name: rot_thirteen }]

                request_with_auth(user.create_new_auth_token) do
                  perform_create_request(recipe_params)
                end

                expect(response.status).to eq 200
              end
            end

            context 'and they are incorrect' do

              it "should not create the recipe with duplicate numbers" do
                recipe_params[:steps_with_positions] = [{position: 1, step_class_name: step}, {position: 1, step_class_name: rot_thirteen }]

                request_with_auth(user.create_new_auth_token) do
                  perform_create_request(recipe_params)
                end

                expect(response.status).to eq 422
              end

              it "should not create the recipe with incorrect numbers" do
                recipe_params[:steps_with_positions] = [{position: 0, step_class_name: step}, {position: 1, step_class_name: rot_thirteen }]

                request_with_auth(user.create_new_auth_token) do
                  perform_create_request(recipe_params)
                end

                expect(response.status).to eq 422
              end

              it "should not create the recipe with skipped steps" do
                recipe_params[:steps_with_positions] = [{position: 1, step_class_name: step}, {position: 6, step_class_name: rot_thirteen }]

                request_with_auth(user.create_new_auth_token) do
                  perform_create_request(recipe_params)
                end

                expect(response.status).to eq 422
              end

              it "should create the recipe with nonsequential numbers" do
                recipe_params[:steps_with_positions] = [{position: 2, step_class_name: step }, {position: 1, step_class_name: rot_thirteen}]

                request_with_auth(user.create_new_auth_token) do
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
                recipe_params[:steps] = [step, rot_thirteen]
              end

              it "should create the recipe with recipe steps" do
                request_with_auth(user.create_new_auth_token) do
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

              it "should create the recipe for nonexistent step classes" do
                recipe_params[:steps] = ["NonexistentStep", rot_thirteen]

                request_with_auth(user.create_new_auth_token) do
                  perform_create_request(recipe_params)
                end

                expect(response.status).to eq 200
              end
            end
          end
        end

      end

      context 'if the recipe is invalid' do
        before do
          recipe_params[:recipe].delete(:name)
        end

        it "should not be successful" do
          request_with_auth(user.create_new_auth_token) do
            perform_create_request(recipe_params)
          end

          expect(response.status).to eq 422
        end
      end
    end

    context 'if no valid token is supplied' do

      it "should not assign anything" do
        request_with_auth do
          perform_create_request(recipe_params)
        end

        expect(response.status).to eq 401
        expect(assigns[:new_recipe]).to be_nil
      end
    end
  end

  describe "PUT update" do

    let!(:recipe)   { create(:recipe, user: user) }

    context 'if a valid token is supplied' do

      it "should assign" do
        request_with_auth(user.create_new_auth_token) do
          perform_put_request(recipe_params.merge(id: recipe.id))
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

      it "should not assign anything" do
        request_with_auth do
          perform_put_request(recipe_params.merge(id: recipe.id))
        end

        expect(response.status).to eq 401
        expect(assigns[:new_recipe]).to be_nil
      end
    end
  end

  describe "GET index" do

    context 'if a valid token is supplied' do

      context 'there are no recipes' do

        it "should find no recipes" do
          request_with_auth(user.create_new_auth_token) do
            perform_index_request
          end

          expect(response.status).to eq 200
          expect(assigns[:recipes]).to eq []
        end

      end

      context 'there are recipes' do
        let!(:other_user)    { create(:user) }
        let!(:recipe_1)      { create(:recipe, user: user) }
        let!(:recipe_2)      { create(:recipe, user: user, active: false) }
        let!(:recipe_3)      { create(:recipe, user: other_user) }

        it "should find the user's recipes" do
          request_with_auth(user.create_new_auth_token) do
            perform_index_request
          end

          expect(response.status).to eq 200
          expect(assigns[:recipes].to_a).to eq [recipe_1]
        end
      end
    end

    context 'if no valid token is supplied' do

      it "should not assign anything" do
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

        it "should return an error" do
          request_with_auth(user.create_new_auth_token) do
            perform_show_request({id: "nonsense"})
          end

          expect(response.status).to eq 404
          expect(assigns[:recipe]).to be_nil
        end

      end

      context 'the recipe exists' do

        context 'the recipe belongs to the user' do
          let!(:recipe)      { create(:recipe, user: user) }

          it "should find the recipe" do
            request_with_auth(user.create_new_auth_token) do
              perform_show_request({id: recipe.id})
            end

            expect(response.status).to eq 200
            expect(assigns[:recipe]).to eq recipe
          end

          context 'and it has conversion chains' do
            let!(:step1)                  { create(:recipe_step, recipe: recipe, position: 1) }
            let!(:conversion_chain)       { create(:conversion_chain, recipe: recipe, executed_at: 2.minutes.ago) }
            let!(:conversion_step)        { create(:executed_conversion_step_success, conversion_chain: conversion_chain) }

            before { recipe.reload }

            it "should find the recipe" do
              request_with_auth(user.create_new_auth_token) do
                perform_show_request({id: recipe.id})
              end

              expect(response.status).to eq 200
              expect(assigns[:recipe]).to eq recipe
            end
          end
        end

        context 'the recipe belongs to another user' do
          let!(:other_user)     { create(:user) }
          let!(:recipe)       { create(:recipe, user: other_user) }

          it "should not find the recipe" do
            request_with_auth(user.create_new_auth_token) do
              perform_show_request({id: recipe.id})
            end

            expect(response.status).to eq 404
            expect(assigns[:recipe]).to be_nil
          end
        end
      end
    end

    context 'if no valid token is supplied' do

      it "should not return anything" do
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

        it "should return an error" do
          request_with_auth(user.create_new_auth_token) do
            perform_destroy_request({id: "nonsense"})
          end

          expect(response.status).to eq 404
          expect(assigns[:recipe]).to be_nil
        end

      end

      context 'the recipe exists' do

        context 'the recipe belongs to the user' do
          let!(:recipe)      { create(:recipe, user: user) }

          it "should find the recipe" do
            request_with_auth(user.create_new_auth_token) do
              perform_destroy_request({id: recipe.id})
            end

            expect(response.status).to eq 200
            expect(assigns[:recipe]).to eq recipe
          end
        end

        context 'the recipe belongs to another user' do
          let!(:other_user)     { create(:user) }
          let!(:recipe)       { create(:recipe, user: other_user) }

          it "should not find the recipe" do
            request_with_auth(user.create_new_auth_token) do
              perform_destroy_request({id: recipe.id})
            end

            expect(response.status).to eq 404
            expect(assigns[:recipe]).to be_nil
          end
        end
      end
    end

    context 'if no valid token is supplied' do

      it "should not return anything" do
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

  def perform_put_request(data)
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