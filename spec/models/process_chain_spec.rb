require 'rails_helper'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

RSpec.describe ProcessChain, type: :model do

  let!(:other_user)         { create(:user) }
  let!(:demo_step)          { base_step_class.to_s }
  let!(:recipe_step)        { create(:recipe_step, step_class_name: demo_step) }
  let!(:recipe)             { recipe_step.recipe }
  let!(:process_chain)      { create(:process_chain, recipe: recipe, user: other_user) }
  let!(:process_step)       { create(:process_step, step_class_name: demo_step, process_chain: process_chain) }

  let!(:target_file_name)   { "plaintext.txt" }
  let!(:target_file)        { File.join(Rails.root, "spec", "fixtures", "files", target_file_name) }

  before { recipe.reload }

  describe 'model validations' do

    it 'has a valid factory' do
      expect(build(:process_chain)).to be_valid
    end

    expects_to_be_invalid_without :process_chain, :user, :recipe

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

        expect(process_chain.executed_at).to_not be_nil
        expect(recursive_file_list(working_directory)).to match_array(["input_files/plaintext.txt", "1/plaintext.txt"])
      end
    end
  end

  describe '#map_results' do
    subject { create(:process_chain) }

    let!(:process_step1)    { create(:process_step, process_chain: subject, position: 1) }
    let!(:process_step2)    { create(:process_step, process_chain: subject, position: 2) }

    let(:some_file)           { File.new(Rails.root.join('spec/fixtures/files/plaintext.txt')) }

    let(:runner_step1)        { double(:process_object, started_at: 10.seconds.ago, finished_at: 5.seconds.ago, errors:[], version: "1.2.7") }
    let(:runner_step2)        { double(:process_object, started_at: 4.seconds.ago, finished_at: 2.seconds.ago, errors:["oh noes!"], version: "0.2.1") }
    let(:runner)              { double(:recipe_process_runner, step_array: [runner_step1, runner_step2]) }

    before do
      subject.reload

      subject.map_results([runner_step1, runner_step2])

      process_step1.reload
      process_step2.reload
    end

    it 'maps the version correctly' do
      expect(process_step1.version).to eq "1.2.7"
      expect(process_step2.version).to eq "0.2.1"
    end

    it 'maps the errors correctly' do
      expect(process_step1.execution_errors).to eq "[]"
      expect(process_step2.execution_errors).to eq "[\"oh noes!\"]"
    end

    it 'maps start times and finishing times correctly' do
      expect(process_step1.started_at.beginning_of_minute).to eq runner_step1.started_at.beginning_of_minute
      expect(process_step1.finished_at.beginning_of_minute).to eq runner_step1.finished_at.beginning_of_minute

      expect(process_step2.started_at.beginning_of_minute).to eq runner_step2.started_at.beginning_of_minute
      expect(process_step2.finished_at.beginning_of_minute).to eq runner_step2.started_at.beginning_of_minute
    end
  end
end