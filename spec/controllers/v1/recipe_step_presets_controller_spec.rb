require 'rails_helper'
require_relative 'version'

RSpec.describe Api::V1::RecipeStepPresetsController do

  let!(:account)           { create(:account) }
  let!(:other_account)     { create(:account) }

  let!(:recipe)            { create(:recipe, account: account, public: true) }
  let!(:recipe_step)       { recipe.recipe_steps.first }

  let!(:new_name)         { "marvellous preset" }
  let!(:new_description)  { "absolutely magical" }
  let!(:new_execution_parameters)  { { "a" => 'b', "c" => 'd'} }

  describe "PUT update" do
    let(:preset_params) {
      {
          recipe_step_preset: {
              name: new_name,
              description: new_description,
              execution_parameters: new_execution_parameters
          },
          id: recipe_step_preset.id
      }
    }
    let!(:recipe_step_preset)            { create(:recipe_step_preset, account: account, recipe_step: recipe_step) }

    context 'with correct info supplied' do
      context 'belonging to that account' do
        it 'updates the values' do
          request_with_auth(account.new_jwt) do
            perform_update_request(preset_params)
          end

          recipe_step_preset.reload

          expect(response.status).to eq 200
          expect(recipe_step_preset.name).to eq new_name
          expect(recipe_step_preset.description).to eq new_description
          expect(recipe_step_preset.execution_parameters).to eq new_execution_parameters
        end
      end

      context "another account's preset" do
        before do
          recipe_step_preset.update_attribute(:account_id, other_account.id)
        end

        it 'does not allow it' do
          request_with_auth(account.new_jwt) do
            perform_update_request(preset_params)
          end

          expect(response.status).to eq 404
        end
      end

      context "on another account's preset" do
        before do
          recipe_step_preset.update_attribute(:account_id, other_account.id)
        end

        it 'does not allow it' do
          request_with_auth(account.new_jwt) do
            perform_update_request(preset_params)
          end

          expect(response.status).to eq 404
        end
      end
    end

    describe 'with no token' do
      specify do
        request_with_auth do
          perform_update_request(preset_params)
        end

        expect(response.status).to eq 401
        expect(assigns[:new_recipe_step_preset]).to be_nil
      end
    end
  end

  describe "POST create" do
    let(:preset_params) {
    {
        recipe_step_preset: {
            name: new_name,
            description: new_description,
            recipe_step_id: recipe_step.id,
            execution_parameters: new_execution_parameters
        }
      }
    }

    context 'if a valid token is supplied' do
      context 'if the recipe step preset is valid' do
        context "on another account's private recipe" do
          before do
            recipe.update_attribute(:account_id, other_account.id)
            recipe.update_attribute(:public, false)
          end

          it 'does not allow it' do
            request_with_auth(account.new_jwt) do
              perform_create_request(preset_params)
            end

            expect(response.status).to eq 404
          end
        end

        context 'and they are valid' do

          it "creates the preset" do
            request_with_auth(account.new_jwt) do
              perform_create_request(preset_params)
            end

            expect(response.status).to eq 200
            new_preset = assigns[:new_recipe_step_preset]
            expect(new_preset).to be_a RecipeStepPreset
            expect(new_preset.name).to eq new_name
            expect(new_preset.description).to eq new_description
            expect(new_preset.account).to eq account
            expect(new_preset.execution_parameters).to eq new_execution_parameters
          end
        end
      end

      context 'if the preset is invalid' do
        context 'if the preset is missing a field' do
          let(:invalid_preset_params) {
            {
                recipe_step_preset: {
                    description: new_description,
                    recipe_step_id: recipe_step.id,
                    execution_parameters: new_execution_parameters
                }
            }
          }

          it "is not successful" do
            request_with_auth(account.new_jwt) do
              perform_create_request(invalid_preset_params)
            end

            expect(response.status).to eq 422
            expect(body_as_json['errors']).to eq ["Validation failed: Name can't be blank"]
          end
        end
      end
    end

    context 'if no valid token is supplied' do
      let(:preset_params) {
        {
            recipe_step_preset: {
                name: new_name,
                description: new_description,
                execution_parameters: new_execution_parameters
            }
        }
      }
      it "does not assign anything" do
        request_with_auth do
          perform_create_request(preset_params)
        end

        expect(response.status).to eq 401
        expect(assigns[:new_recipe_step_preset]).to be_nil
      end
    end
  end

  describe "POST create_from_process_step" do
    let!(:execution_params)         { { "tool" => "draw-knife", "wood" => "matai", "bird" => "South Island kōkako" } }
    let!(:process_chain)            { create(:process_chain, recipe: recipe, account: account) }
    let!(:process_step)             { create(:process_step, process_chain: process_chain, execution_parameters: execution_params) }

    let(:preset_params) {
    {
        recipe_step_preset: {
            name: new_name,
            description: new_description
        },
        process_step_id: process_step.id
      }
    }

    context 'if a valid token is supplied' do
      context 'if the recipe step preset is valid' do
        context "on another account's private recipe" do
          before do
            recipe.update_attribute(:account_id, other_account.id)
            recipe.update_attribute(:public, false)
          end

          it 'does not allow it' do
            request_with_auth(account.new_jwt) do
              perform_create_from_process_step_request(preset_params)
            end

            expect(response.status).to eq 404
          end
        end

        context 'and they are valid' do

          it "creates the preset" do
            request_with_auth(account.new_jwt) do
              perform_create_from_process_step_request(preset_params)
            end

            expect(response.status).to eq 200
            new_preset = assigns[:new_recipe_step_preset]
            expect(new_preset).to be_a RecipeStepPreset
            expect(new_preset.name).to eq new_name
            expect(new_preset.description).to eq new_description
            expect(new_preset.account).to eq account
            expect(new_preset.execution_parameters).to eq execution_params
          end
        end
      end

      context 'if the preset is invalid' do
        context 'if the preset is missing a field' do
          let(:invalid_preset_params) {
            {
                recipe_step_preset: {
                    description: new_description,
                    recipe_step_id: recipe_step.id
                },
                process_step_id: process_step.id
            }
          }

          it "is not successful" do
            request_with_auth(account.new_jwt) do
              perform_create_from_process_step_request(invalid_preset_params)
            end

            expect(response.status).to eq 422
            expect(body_as_json['errors']).to eq ["Validation failed: Name can't be blank"]
          end
        end

        context 'if the process chain does not belong to that account' do
          before { process_chain.update_attribute(:account_id, other_account.id) }

          it "is not successful" do
            request_with_auth(account.new_jwt) do
              perform_create_from_process_step_request(preset_params)
            end

            expect(response.status).to eq 404
          end
        end
      end
    end

    context 'if no valid token is supplied' do
      let(:preset_params) {
        {
            recipe_step_preset: {
                name: new_name,
                description: new_description,
                execution_parameters: new_execution_parameters
            }
        }
      }
      it "does not assign anything" do
        request_with_auth do
          perform_create_from_process_step_request(preset_params)
        end

        expect(response.status).to eq 401
        expect(assigns[:new_recipe_step_preset]).to be_nil
      end
    end
  end

  describe "GET index" do

    context 'if a valid token is supplied' do
      context 'there are no presets' do
        it 'returns none' do
          request_with_auth(account.new_jwt) do
            perform_index_request(recipe_step_id: recipe_step.id)
          end

          expect(response.status).to eq 200
          expect(assigns[:recipe_step_presets]).to eq []
        end
      end

      context 'there are presets' do

        context "for their own recipe" do
          let!(:recipe_1)      { create(:recipe, name: "recipe1", account: account) }
          let!(:preset_1)      { create(:recipe_step_preset, recipe_step: recipe_1.recipe_steps.first, account: account) }
          let!(:preset_2)      { create(:recipe_step_preset, recipe_step: recipe_1.recipe_steps.first, account: other_account) }

          specify do
            request_with_auth(account.new_jwt) do
              perform_index_request(recipe_step_id: recipe_1.recipe_steps.first.id)
            end

            expect(response.status).to eq 200
            expect(assigns[:recipe_step_presets].to_a).to eq [preset_1]
          end
        end

        context 'for an inactive recipe' do
          let!(:recipe_2)      { create(:recipe, name: "recipe2", account: account, active: false) }
          let!(:preset_3)      { create(:recipe_step_preset, recipe_step: recipe_2.recipe_steps.first, account: account) }
          let!(:preset_4)      { create(:recipe_step_preset, recipe_step: recipe_2.recipe_steps.first, account: other_account) }

          context 'belongs to another account' do
            before { recipe_2.update_attribute(:account_id, other_account.id) }
            specify do
              request_with_auth(account.new_jwt) do
                perform_index_request(recipe_step_id: recipe_2.recipe_steps.first.id)
              end

              expect(response.status).to eq 404
              expect(assigns[:recipe_step_presets]).to be_nil
            end
          end

          context 'belongs to that account' do
            specify do
              request_with_auth(account.new_jwt) do
                perform_index_request(recipe_step_id: recipe_2.recipe_steps.first.id)
              end

              expect(response.status).to eq 200
              expect(assigns[:recipe_step_presets].to_a).to eq [preset_3]
            end
          end
        end

        context 'for an private recipe belonging to someone else' do
          let!(:recipe_3)      { create(:recipe, name: "recipe3", account: other_account, public: false) }
          let!(:preset_5)      { create(:recipe_step_preset, recipe_step: recipe_3.recipe_steps.first, account: account) }
          let!(:preset_6)      { create(:recipe_step_preset, recipe_step: recipe_3.recipe_steps.first, account: other_account) }

          specify do
            request_with_auth(account.new_jwt) do
              perform_index_request(recipe_step_id: recipe_3.recipe_steps.first.id)
            end

            expect(response.status).to eq 404
            expect(assigns[:recipe_step_presets]).to be_nil
          end
        end

        context 'for a public recipe belonging to someone else' do
          let!(:recipe_4)      { create(:recipe, name: "recipe4", account: other_account, public: true) }
          let!(:preset_7)      { create(:recipe_step_preset, recipe_step: recipe_4.recipe_steps.first, account: account) }
          let!(:preset_8)      { create(:recipe_step_preset, recipe_step: recipe_4.recipe_steps.first, account: other_account) }

          specify do
            request_with_auth(account.new_jwt) do
              perform_index_request(recipe_step_id: recipe_4.recipe_steps.first.id)
            end

            expect(response.status).to eq 200
            expect(assigns[:recipe_step_presets]).to eq [preset_7]
          end
        end
      end
    end

    context 'if no valid token is supplied' do
      it "does not assign anything" do
        request_with_auth do
          perform_index_request({recipe_step_id: recipe.recipe_steps.first.id})
        end

        expect(response.status).to eq 401
        expect(assigns[:recipe_step_presets]).to be_nil
      end
    end
  end

  describe "GET show" do
    let!(:recipe_step_preset)            { create(:recipe_step_preset, account: account, recipe_step: recipe_step) }

    context 'if a valid token is supplied' do
      context 'if the preset does not exist' do

        it "returns an error" do
          request_with_auth(account.new_jwt) do
            perform_show_request({id: "nonsense"})
          end

          expect(response.status).to eq 404
          expect(assigns[:recipe_step_preset]).to be_nil
        end

      end

      context 'the preset exists' do
        context 'the recipe belongs to the account' do

          it "finds the preset" do
            request_with_auth(account.new_jwt) do
              perform_show_request({id: recipe_step_preset.id})
            end

            expect(response.status).to eq 200
            expect(assigns[:recipe_step_preset]).to eq recipe_step_preset
          end
        end

        context 'the recipe belongs to another account and is available' do
          let!(:preset2)              { create(:recipe_step_preset, account: other_account, recipe_step: recipe.recipe_steps.first) }

          it "does not find the preset" do
            request_with_auth(account.new_jwt) do
              perform_show_request({id: preset2.id})
            end

            expect(response.status).to eq 404
            expect(assigns[:recipe_step_preset]).to be_nil
          end
        end

        context 'for an inactive recipe' do
          let!(:recipe1)      { create(:recipe, account: account, active: false) }
          let!(:preset1)      { create(:recipe_step_preset, recipe_step: recipe1.recipe_steps.first, account: account) }

          context 'belongs to that account' do
            specify do
              request_with_auth(account.new_jwt) do
                perform_show_request(id: preset1.id)
              end

              expect(response.status).to eq 200
              expect(assigns[:recipe_step_preset]).to eq preset1
            end
          end

          context 'belongs to another account' do
            before { recipe1.update_attribute(:account_id, other_account.id) }
            specify do
              request_with_auth(account.new_jwt) do
                perform_show_request(id: preset1.id)
              end

              expect(response.status).to eq 404
            end
          end
        end

        context 'for a private recipe belonging to someone else' do
          let!(:recipe1)      { create(:recipe, name: "recipe3", account: other_account, public: false) }
          let!(:preset1)      { create(:recipe_step_preset, recipe_step: recipe1.recipe_steps.first, account: account) }

          specify do
            request_with_auth(account.new_jwt) do
              perform_show_request(id: preset1.id)
            end

            expect(response.status).to eq 404
          end
        end

        context 'for a public recipe belonging to someone else' do
          let!(:recipe1)      { create(:recipe, name: "recipe4", account: other_account, public: true) }
          let!(:preset1)      { create(:recipe_step_preset, recipe_step: recipe1.recipe_steps.first, account: account) }

          specify do
            request_with_auth(account.new_jwt) do
              perform_show_request(id: preset1.id)
            end

            expect(response.status).to eq 200
            expect(assigns[:recipe_step_preset]).to eq preset1
          end
        end
      end
    end

    context 'if no valid token is supplied' do

      it "does not return anything" do
        request_with_auth do
          perform_show_request({id: recipe_step_preset.id})
        end

        expect(response.status).to eq 401
        expect(assigns[:recipe_step_preset]).to be_nil
      end
    end
  end

  describe "DELETE destroy" do

    context 'if a valid token is supplied' do
      context 'if the preset does not exist' do
        it "returns an error" do
          request_with_auth(account.new_jwt) do
            perform_destroy_request({id: "nonsense"})
          end
          expect(response.status).to eq 404
          expect(assigns[:recipe_step_preset]).to be_nil
        end
      end

      context 'the preset exists' do
        let!(:recipe_step_preset)            { create(:recipe_step_preset, account: account, recipe_step: recipe_step) }
        context 'the preset belongs to the account' do
          it "allows it to be destroyed" do
            request_with_auth(account.new_jwt) do
              perform_destroy_request({id: recipe_step_preset.id})
            end

            expect(response.status).to eq 200
            expect(assigns[:recipe_step_preset]).to eq recipe_step_preset
          end
        end

        context 'the preset belongs to another account' do
          before { recipe_step_preset.update_attribute(:account_id, other_account.id) }

          it "allows it to be destroyed" do
            request_with_auth(account.new_jwt) do
              perform_destroy_request(id: recipe_step_preset.id)
            end

            expect(response.status).to eq 404
            expect(assigns[:recipe_step_preset]).to eq nil
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
        expect(assigns[:recipe_step_preset]).to be_nil
      end
    end
  end

  # request.headers.merge!(auth_headers)
  # this is special for controller tests - you can't just merge them in manually

  def perform_create_request(data = {})
    post_create_request(version, data)
  end

  def perform_create_from_process_step_request(data = {})
    post_create_from_chain_request(version, data)
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