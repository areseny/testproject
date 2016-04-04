require 'rails_helper'

RSpec.describe RecipeStep, type: :model do

  describe 'model validations' do

    it 'has a valid factory' do
      expect(FactoryGirl.build(:recipe_step)).to be_valid
    end

    expects_to_be_invalid_without :recipe_step, :recipe, :position

    describe 'position' do
      it 'should be an integer' do
        expect(FactoryGirl.build(:recipe_step, position: 2.4)).to_not be_valid
      end

      it 'should be positive' do
        expect(FactoryGirl.build(:recipe_step, position: -2)).to_not be_valid
      end

      it 'should be greater than 0' do
        expect(FactoryGirl.build(:recipe_step, position: 0)).to_not be_valid
      end

      it 'should be greater than 0' do
        expect(FactoryGirl.build(:recipe_step, position: 1)).to be_valid
      end

      it 'should be unique to that recipe / position combination' do
        recipe = FactoryGirl.create(:recipe)
        FactoryGirl.create(:recipe_step, recipe: recipe, position: 1)
        expect(FactoryGirl.build(:recipe_step, recipe: recipe, position: 1)).to_not be_valid
      end

    end
  end
end