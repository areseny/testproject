require 'rails_helper'
require_relative '../version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe "User executes a ROT13 recipe" do

  # URL: /api/recipes/:id/execute
  # Method: GET
  # Execute a specific recipe belonging to the current user

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X GET http://localhost:3000/api/recipes/:id/execute

  let!(:user)             { FactoryGirl.create(:user, password: "password", password_confirmation: "password") }
  let!(:auth_headers)     { user.create_new_auth_token }
  let!(:text_file)        { fixture_file_upload('spec/fixtures/files/plaintext.txt', 'text/plain') }

  let!(:recipe)           { FactoryGirl.create(:recipe, user: user) }

  let!(:execution_params) {
    {
        input_file: text_file,
        id: recipe.id
    }
  }

    let!(:conversion_class)  { FactoryGirl.create(:step_class, name: "RotThirteen") }
    let!(:step1)             { FactoryGirl.create(:recipe_step, recipe: recipe, position: 1, step_class: conversion_class) }

  context 'if the conversion is successful' do
    before do
      perform_execute_request(auth_headers, execution_params)
    end

    it 'should be successful' do

    end

    it 'should be successful' do
      expect(response.status).to eq(200)
      expect(body_as_json['conversion_chain']).to_not be_nil
      expect(body_as_json['conversion_chain']['conversion_steps'].count).to eq 1
      body_as_json['conversion_chain']['conversion_steps'].map do |s|
        expect(s['conversion_errors']).to eq ""
      end
      # expect(body_as_json['conversion_chain']['conversion_steps'].sort_by{|e| e['position'].to_i}.map{|e| e['output_file_path']}).to eq [true, true]
    end

    it 'should have an expected output file' do
      wait_for_async
      result = ConversionChain.last.output_file
      expect(result.read).to eq "Guvf vf fbzr grkg."
    end
  end

  def perform_execute_request(auth_headers, data)
    execute_recipe_request(version, auth_headers, data)
  end
end