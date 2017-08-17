require 'rails_helper'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

RSpec.describe ProcessChain, type: :model do

  let!(:other_account)      { create(:account) }
  let!(:demo_step)          { base_step_class.to_s }
  let!(:recipe)             { create(:recipe) }
  let(:recipe_step)         { recipe.recipe_steps.first }
  let!(:process_chain)      { create(:process_chain, recipe: recipe, account: other_account) }
  let!(:process_step)       { create(:process_step, step_class_name: demo_step, process_chain: process_chain) }

  let!(:target_file_name)   { "plaintext.txt" }
  let!(:target_file)        { File.join(Rails.root, "spec", "fixtures", "files", target_file_name) }

  before { recipe.reload }

  describe 'model validations' do

    it 'has a valid factory' do
      expect(build(:process_chain)).to be_valid
    end

    expects_to_be_invalid_without :process_chain, :account, :recipe

    it 'generates a slug automatically' do
      expect(create(:process_chain, slug: nil).slug).to_not be_nil
    end
  end

  describe '#step_classes' do

    before do
      process_chain.update_attribute(:recipe_id, recipe_step.recipe.id)
    end

    it 'returns the step classes' do
      expect(process_chain.step_classes).to eq [base_step_class]
    end
  end

  describe '#execute_process!' do

    let(:input_file)    { double(:file, path: target_file, original_filename: target_file_name, tempfile: File.open(target_file)) }

    context "if the chain hasn't been saved yet" do
      let(:chain)   { build(:process_chain) }

      it 'fails' do
        expect{chain.execute_process!(input_files: [input_file])}.to raise_error("Chain not saved yet")
        expect(chain.executed_at).to be_nil
      end
    end

    context "if the chain has been saved" do

      let(:working_directory)   { process_chain.send(:working_directory) }

      before  do
        create_directory_if_needed(process_chain.input_files_directory)
        FileUtils.cp(target_file, process_chain.input_files_directory)
      end

      it 'successfully starts execution' do
        process_chain.execute_process!(input_files: [input_file])

        expect(process_chain.reload.executed_at).to_not be_nil
        expect(recursive_file_list(working_directory)).to match_array(["input_files/plaintext.txt", "1/plaintext.txt"])
      end
    end
  end
end