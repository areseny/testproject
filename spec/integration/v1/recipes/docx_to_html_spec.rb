require 'rails_helper'
require_relative '../version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe "User executes a single recipe" do

  # URL: /api/recipes/:id/execute
  # Method: GET
  # Execute a specific recipe belonging to the current user

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X GET http://localhost:3000/api/recipes/:id/execute

  describe "POST execute recipe" do

    let!(:user)             { create(:user, password: "password", password_confirmation: "password") }
    let!(:auth_headers)     { user.create_new_auth_token }
    let!(:docx_file)        { fixture_file_upload('files/basic_doc.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }

    let!(:recipe)           { create(:recipe, user: user) }

    let!(:execution_params) {
      {
          input_file: docx_file,
          id: recipe.id
      }
    }

    context 'if user is signed in' do
      let!(:conversion_class)  { "InkStep::BasicStep" }
      let!(:step1)             { create(:recipe_step, recipe: recipe, position: 1, step_class_name: conversion_class) }

      context 'and execution is successful' do

        before do
          perform_execute_request(auth_headers, execution_params)
        end

        it 'returns the objects' do
          expect(response.status).to eq(200)
          expect(body_as_json['conversion_chain']['successful']).to_not be_nil
        end

        it 'includes the associated steps' do
          expect(body_as_json['conversion_chain']['conversion_steps'].count).to eq 1
          body_as_json['conversion_chain']['conversion_steps'].map do |s|
            expect(s['execution_errors']).to eq ""
          end
          # expect(body_as_json['conversion_chain']['conversion_steps'].sort_by{|e| e['position'].to_i}.map{|e| e['output_file_path']}).to eq [true, true]
        end

      end

    end
  end
  
  def perform_execute_request(auth_headers, data)
    execute_recipe_request(version, auth_headers, data)
  end
end