require 'rails_helper'

RSpec.describe RecipeStep, type: :model do

  describe 'model validations' do

    it 'has a valid factory' do
      expect(build(:recipe_step, position: 2)).to be_valid
    end

    expects_to_be_invalid_without :recipe_step, :recipe, :position, :step_class_name

    describe 'position' do
      it 'is an integer' do
        expect(build(:recipe_step, position: 2.4)).to_not be_valid
      end

      it 'is positive' do
        expect(build(:recipe_step, position: -2)).to_not be_valid
      end

      it 'is greater than 0' do
        expect(build(:recipe_step, position: 0)).to_not be_valid
      end

      it 'is greater than 0' do
        expect(build(:recipe_step, position: 6)).to be_valid
      end

      it 'is unique to that recipe / position combination' do
        recipe = create(:recipe)
        create(:recipe_step, recipe: recipe, position: 2)
        expect(build(:recipe_step, recipe: recipe, position: 2)).to_not be_valid
      end

    end
  end
end