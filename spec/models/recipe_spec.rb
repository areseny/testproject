require 'rails_helper'

RSpec.describe Recipe, type: :model do

  let!(:user)           { create(:user) }
  let!(:other_user)     { create(:user) }

  describe 'model validations' do

    it 'has a valid factory' do
      expect(build(:recipe)).to be_valid
    end

    expects_to_be_invalid_without :recipe, :name, :user, :active, :public
  end

  describe 'available recipes to user scope' do

    let!(:recipe1) { create(:recipe, public: true, user: other_user) }
    let!(:recipe2) { create(:recipe, public: true, user: user) }
    let!(:recipe3) { create(:recipe, public: false, user: user) }
    let!(:recipe4) { create(:recipe, public: false, user: other_user) }

    specify do
      expect(Recipe.available_to_user(user.id)).to match_array([recipe1, recipe2, recipe3])
      expect(Recipe.available_to_user(other_user.id)).to match_array([recipe1, recipe2, recipe4])
    end
  end

  describe '#clone_to_conversion_chain' do

    context 'if the recipe is public and belongs to another user' do
      let(:other_users_public_recipe) { create(:recipe, public: true, user: other_user) }
      let(:some_file)     { double(:file) }

      it 'clones to belong to the current user' do
        chain = other_users_public_recipe.clone_to_conversion_chain(input_file: some_file, user: user)
        expect(chain.user).to eq user
      end
    end

    context 'if there is no file' do
      let(:my_recipe)     { create(:recipe, public: false, user: user) }

      it 'fails' do
        expect{my_recipe.clone_to_conversion_chain(input_file: nil, user: user)}.to raise_error(ExecutionErrors::NoFileSuppliedError)
      end
    end

  end
end

def clone_to_conversion_chain(input_file)
  raise ExecutionErrors::NoFileSuppliedError.new unless input_file
  new_chain = conversion_chains.new(user: user, input_file: input_file)
  recipe_steps.each do |recipe_step|
    new_chain.conversion_steps.new(position: recipe_step.position, step_class_name: recipe_step.step_class_name)
  end
  new_chain
end