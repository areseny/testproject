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
      expect(Recipe.available_to_account(account.id, account.admin?)).to match_array([recipe1, recipe2, recipe3])
      expect(Recipe.available_to_account(other_account.id, other_account.admin?)).to match_array([recipe1, recipe2, recipe4])
    end
  end

  describe 'available process chains to account scope' do

    let!(:recipe1)          { create(:recipe, public: true, account: other_account) }
    let!(:recipe2)          { create(:recipe, public: true, account: account) }
    let!(:process_chain1)   { create(:process_chain, recipe: recipe1, account: account) }
    let!(:process_chain2)   { create(:process_chain, recipe: recipe2, account: account) }
    let!(:process_chain3)   { create(:process_chain, recipe: recipe1, account: other_account) }
    let!(:process_chain4)   { create(:process_chain, recipe: recipe2, account: other_account) }

    specify do
      expect(recipe1.available_process_chains(account)).to match_array([process_chain1, process_chain2])
      expect(recipe2.available_process_chains(other_account)).to match_array([process_chain3, process_chain4])
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

  describe '#attempt_to_destroy!' do
    context 'and the account IS NOT an admin' do
      context 'the recipe belongs to the account' do
        let!(:recipe)      { create(:recipe, account: account) }

        context 'the recipe has NO process chains' do
          it "allows it to be destroyed" do
            expect{recipe.attempt_to_destroy!(account)}.to change(Recipe, :count).by(-1)
            expect{recipe.reload}.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        context 'the recipe has only process chains belonging to the account' do
          let!(:process_chain)  { create(:process_chain, account: account, recipe: recipe) }

          it "destroys both the recipe and account's process chains" do
            expect{recipe.attempt_to_destroy!(account)}.to change(ProcessChain, :count).by(-1)
            expect{recipe.reload}.to raise_error(ActiveRecord::RecordNotFound)
            expect{process_chain.reload}.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        context 'the recipe has a process chain belonging to others' do
          let!(:process_chain)  { create(:process_chain, account: other_account, recipe: recipe) }

          it "does not allow it to be destroyed" do
            expect{recipe.attempt_to_destroy!(account)}.to raise_error(RuntimeError)
            expect{recipe.reload}.to_not raise_error
            expect{process_chain.reload}.to_not raise_error
          end
        end
      end

      context 'the recipe belongs to another account' do
        let!(:other_account)     { create(:account) }
        let!(:recipe)       { create(:recipe, account: other_account) }

        it "does not allow it to be destroyed" do
          expect{recipe.attempt_to_destroy!(account)}.to raise_error(RuntimeError)
          expect{recipe.reload}.to_not raise_error
        end
      end
    end

    context 'and the account IS an admin' do
      before do
        create(:account_role, account: account, role: "admin")
        account.reload
        recipe.reload
      end

      context 'the recipe belongs to the account' do
        let!(:recipe)      { create(:recipe, account: account) }

        context 'the recipe has NO process chains' do
          it "allows it to be destroyed" do
            expect{recipe.attempt_to_destroy!(account)}.to change(Recipe, :count).by(-1)
            expect{recipe.reload}.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        context 'the recipe has only process chains belonging to the account' do
          let!(:process_chain)  { create(:process_chain, account: account, recipe: recipe) }

          it "destroys the recipe" do
            recipe.reload
            account.reload

            expect{recipe.attempt_to_destroy!(account)}.to change(Recipe, :count).by(-1)
            expect{recipe.reload}.to raise_error(ActiveRecord::RecordNotFound)
            expect{process_chain.reload}.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        context 'the recipe has a process chain belonging to others' do
          let!(:process_chain)  { create(:process_chain, account: other_account, recipe: recipe) }

          it "allows it to be destroyed anyway" do
            expect{recipe.attempt_to_destroy!(account)}.to change(Recipe, :count).by(-1)
            expect{recipe.reload}.to raise_error(ActiveRecord::RecordNotFound)
            expect{process_chain.reload}.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      context 'the recipe belongs to another account' do
        let!(:other_account)     { create(:account) }
        let!(:recipe)            { create(:recipe, account: other_account) }

        it "destroys the recipe" do
          expect{recipe.attempt_to_destroy!(account)}.to change(Recipe, :count).by(-1)
          expect{recipe.reload}.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end


  describe 'favouriting' do
    subject             { create(:recipe) }
    let(:other_recipe)  { create(:recipe) }

    describe 'mark as favourite' do

      context 'recipe has already been favourited by that account' do
        before do
          create(:recipe_favourite, recipe: subject, account: account)
        end

        specify do
          subject.mark_as_favourite!(account)

          expect(subject.favourited_by?(account)).to be_truthy
        end
      end

      context 'recipe has not been favourited by that account' do
        it 'recipe is still favourited' do
          subject.mark_as_favourite!(account)

          expect(subject.favourited_by?(account)).to be_truthy
        end
      end
    end

    describe 'unmark as favourite' do

      context 'recipe has been favourited by that account' do
        before do
          create(:recipe_favourite, recipe: subject, account: account)
        end

        specify do
          subject.unmark_as_favourite!(account)

          expect(subject.favourited_by?(account)).to be_falsey
        end
      end

      context 'recipe has not been favourited by that account' do
        it 'recipe is not favourited' do
          subject.unmark_as_favourite!(account)

          expect(subject.favourited_by?(account)).to be_falsey
        end
      end
    end

    describe '#favourited_by?' do

      context 'that recipe has not been favourited' do
        specify do
          expect(subject.favourited_by?(account)).to be_falsey
        end
      end

      context 'that recipe has been favourited by another account only' do
        before do
          create(:recipe_favourite, recipe: subject, account: other_account)
        end

        specify do
          expect(subject.favourited_by?(account)).to be_falsey
        end
      end

      context 'a different recipe has been favourited by that account' do
        before do
          create(:recipe_favourite, recipe: other_recipe, account: account)
        end

        specify do
          expect(subject.favourited_by?(account)).to be_falsey
        end
      end

      context 'that recipe has been favourited by that account' do
        before do
          create(:recipe_favourite, recipe: subject, account: account)
        end

        specify do
          expect(subject.favourited_by?(account)).to be_truthy
        end
      end
    end

  end
end