require 'rails_helper'
require_relative '../version'

describe "User lists all their recipes" do

  # URL: /api/recipes/
  # Method: GET
  # Get all the recipes belonging to the current user

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X GET http://localhost:3000/api/recipes

  describe "GET index recipe" do

    let!(:user)               { create(:user, password: "password", password_confirmation: "password") }
    let!(:other_user)         { create(:user) }

    let!(:auth_headers)       { user.create_new_auth_token }
    let!(:recipe)           { create(:recipe, user: user) }
    let!(:inactive_recipe)  { create(:recipe, user: user, active: false) }
    let!(:other_recipe)     { create(:recipe, user: other_user) }

    context 'if user is signed in' do

      context 'and there are some active recipes that belong to the user' do

        before do
          perform_index_request(auth_headers)
        end

        it 'responds with success' do
          expect(response.status).to eq(200)
        end

        it 'returns a list of Recipe objects' do
          expect(body_as_json.count).to eq 1

          expect(body_as_json['recipes'][0]['name']).to eq recipe.name
          expect(body_as_json['recipes'][0]['description']).to eq recipe.description
          expect(body_as_json['recipes'][0]['user_id']).to eq recipe.user.id
          expect(body_as_json['recipes'][0]['active']).to eq recipe.active
          expect(body_as_json['recipes'][0]['public']).to eq recipe.public
        end

        context 'and there are some steps and conversion chains' do
          let!(:step1)                { create(:recipe_step, recipe: recipe, position: 1, step_class_name: "RotThirteenStep") }
          let!(:step2)                { create(:recipe_step, recipe: recipe, position: 2, step_class_name: "EpubToCalibreStep") }
          let!(:conversion_chain1)    { create(:conversion_chain, recipe: recipe, executed_at: 5.minutes.ago) }
          let!(:conversion_step1a)    { create(:executed_conversion_step_success, conversion_chain: conversion_chain1, position: 1, step_class_name: "RotThirteenStep") }
          let!(:conversion_step1b)    { create(:executed_conversion_step_success, conversion_chain: conversion_chain1, position: 2, step_class_name: "EpubToCalibreStep") }
          let!(:conversion_chain2)    { create(:conversion_chain, recipe: recipe, executed_at: 2.minutes.ago) }
          let!(:conversion_step2a)    { create(:executed_conversion_step_success, conversion_chain: conversion_chain2, position: 1, step_class_name: "RotThirteenStep") }
          let!(:conversion_step2b)    { create(:executed_conversion_step_success, conversion_chain: conversion_chain2, position: 2, step_class_name: "EpubToCalibreStep") }

          before do
            [recipe, conversion_chain1, conversion_chain2, conversion_step1a, conversion_step1b, conversion_step2a, conversion_step2b].each do |thing|
              thing.reload
            end
          end

          it 'returns chain information in the right order' do
            perform_index_request(auth_headers)

            expect(body_as_json['recipes'][0]['conversion_chains'].count).to eq 2
            expect(body_as_json['recipes'][0]['conversion_chains'][0]['conversion_steps'].count).to eq 2
            expect(body_as_json['recipes'][0]['conversion_chains'][0]['id']).to eq conversion_chain2.id
            expect(body_as_json['recipes'][0]['conversion_chains'][1]['id']).to eq conversion_chain1.id
            expect(body_as_json['recipes'][0]['conversion_chains'][1]['conversion_steps'].count).to eq 2
          end

          it 'gets the information correct' do
            perform_index_request(auth_headers)

            expect(body_as_json['recipes'][0]['conversion_chains'][0]['conversion_steps'][0]['position']).to eq 1
            expect(body_as_json['recipes'][0]['conversion_chains'][0]['conversion_steps'][0]['step_class_name']).to eq conversion_step1a.step_class_name
            expect(body_as_json['recipes'][0]['conversion_chains'][0]['conversion_steps'][1]['position']).to eq 2
            expect(body_as_json['recipes'][0]['conversion_chains'][0]['conversion_steps'][1]['step_class_name']).to eq conversion_step1b.step_class_name


            expect(body_as_json['recipes'][0]['conversion_chains'][1]['conversion_steps'][0]['position']).to eq 1
            expect(body_as_json['recipes'][0]['conversion_chains'][1]['conversion_steps'][0]['step_class_name']).to eq conversion_step2a.step_class_name
            expect(body_as_json['recipes'][0]['conversion_chains'][1]['conversion_steps'][1]['position']).to eq 2
            expect(body_as_json['recipes'][0]['conversion_chains'][1]['conversion_steps'][1]['step_class_name']).to eq conversion_step2b.step_class_name
          end
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
          expect(body_as_json.to_a).to eq [['recipes', []]]
        end
      end
    end

    context 'if no user is signed in' do
      before do
        perform_index_request({})
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
        expire_token(user, auth_headers['client'])
        perform_index_request({})
      end

      it 'raises an error' do
        expect(response.status).to eq(401)
      end

      it 'provides a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end

  end
  
  def perform_index_request(auth_headers)
    index_recipe_request(version, auth_headers)
  end
end