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

    context 'if the execution has parameters' do
      let(:recipe)        { create(:recipe, public: true, account: other_account) }
      let(:some_file)     { double(:file) }

      let!(:execution_parameters)   { { "1" => { "data" => { "food" => "chocolate covered potato chips", "animal" => "norwegian forest cat", "colour" => "russet" } } } }

      it 'clones and the chain belongs to the current account' do
        chain = recipe.clone_to_process_chain(account: account, execution_parameters: execution_parameters)
        expect(chain.execution_parameters).to eq execution_parameters
      end

      context 'if the recipe step also has parameters' do
        let(:step)  { recipe.recipe_steps.first }

        before do
          step.update_attribute(:execution_parameters, { "food" => "lasagne", "animal" => "wildebeest", "tool" => "shovel"})
        end

        it 'overrides the existing recipe step parameters with the execution parameters' do
          chain = recipe.clone_to_process_chain(account: account, execution_parameters: execution_parameters)
          expect(chain.process_steps.first.execution_parameters).to eq({"food" => "chocolate covered potato chips", "animal" => "norwegian forest cat", "colour" => "russet", "tool" => "shovel" })
        end
      end
    end
  end
end