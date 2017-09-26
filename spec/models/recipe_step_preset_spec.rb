require 'rails_helper'

RSpec.describe RecipeStepPreset, type: :model do

  describe 'model validations' do
    let!(:recipe)        { build(:recipe) }
    let!(:recipe_step)   { recipe.recipe_steps.first }

    it 'has a valid factory' do

      expect(build(:recipe_step_preset, recipe_step: recipe_step)).to be_valid
    end

    it 'needs a name' do
      expect(build(:recipe_step_preset, recipe_step: recipe_step, name: nil)).to_not be_valid
    end

    it 'needs a recipe step' do
      expect(build(:recipe_step_preset, recipe_step: nil)).to_not be_valid
    end

    it 'needs an account' do
      expect(build(:recipe_step_preset, recipe_step: recipe_step, account: nil)).to_not be_valid
    end
  end
end