require 'rails_helper'

RSpec.describe Recipe, type: :model do

  let!(:account)           { create(:account) }
  let!(:other_account)     { create(:account) }

  describe 'model validations' do

    it 'has a valid factory' do
      expect(build(:recipe)).to be_valid
    end

    expects_to_be_invalid_without :recipe, :name, :account, :active, :public

    it 'is invalid if it has no steps' do
      recipe = build(:recipe)
      recipe.recipe_steps = []
      expect(recipe).to_not be_valid
    end
  end

  describe 'available recipes to account scope' do

    let!(:recipe1) { create(:recipe, public: true, account: other_account) }
    let!(:recipe2) { create(:recipe, public: true, account: account) }
    let!(:recipe3) { create(:recipe, public: false, account: account) }
    let!(:recipe4) { create(:recipe, public: false, account: other_account) }

    specify do
      expect(Recipe.available_to_account(account.id)).to match_array([recipe1, recipe2, recipe3])
      expect(Recipe.available_to_account(other_account.id)).to match_array([recipe1, recipe2, recipe4])
    end
  end

  describe '#clone_to_process_chain' do

    context 'if the recipe is public and belongs to another account' do
      let(:other_accounts_public_recipe) { create(:recipe, public: true, account: other_account) }
      let(:some_file)     { double(:file) }

      it 'clones and the chain belongs to the current account' do
        chain = other_accounts_public_recipe.clone_to_process_chain(account: account)
        expect(chain.account).to eq account
      end
    end
  end
end