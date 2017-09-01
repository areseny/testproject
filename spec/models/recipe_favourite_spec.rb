require 'rails_helper'

RSpec.describe RecipeFavourite, type: :model do

  let!(:account)           { create(:account) }
  let!(:recipe)            { create(:recipe) }

  describe 'model validations' do

    it 'has a valid factory' do
      expect(build(:recipe_favourite)).to be_valid
    end

    expects_to_be_invalid_without :recipe_favourite, :account, :recipe

    it 'is invalid if the account already has that recipe favourited' do
      create(:recipe_favourite, account: account, recipe: recipe)
      new_recipe_favourite = build(:recipe_favourite, account: account, recipe: recipe)

      expect(new_recipe_favourite).to_not be_valid
    end
  end
end