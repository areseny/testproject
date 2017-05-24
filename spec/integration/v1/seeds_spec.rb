require 'rails_helper'

describe "Seeding the DB with default recipes and a demo account" do

  # URL: /api/recipes/:id/
  # Method: PUT or PATCH
  # Update the details of a recipe.

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: account@example.com, auth_token: asdf" -X PUT http://localhost:3000/api/recipes/:id


  it 'creates a new account and a service' do
    load "#{Rails.root}/db/seeds.rb"

    expect(Account.count).to eq 1
    expect(Account.first.email).to eq "inkdemo@example.com"
    expect(Account.first.service).to be_a Service
  end

  it 'creates two recipes' do
    load "#{Rails.root}/db/seeds.rb"

    expect(Recipe.count).to eq 2
    expect(Recipe.all.map(&:name)).to match_array ["Rot 13 and SHOUTIFIED", "Editoria Typescript"]
    expect(Recipe.first.recipe_steps.count).to eq 2
  end
end
