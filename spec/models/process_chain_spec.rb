require 'rails_helper'

RSpec.describe ProcessChain, type: :model do

  let!(:other_user)       { create(:user) }
  let!(:demo_step)        { "InkStep::BasicStep" }
  let!(:recipe_step)      { create(:recipe_step, step_class_name: demo_step) }
  let!(:recipe)           { recipe_step.recipe }
  let!(:process_chain)    { create(:process_chain, recipe: recipe, user: other_user) }
  let!(:process_step)     { create(:process_step, step_class_name: demo_step, process_chain: process_chain) }

  before { recipe.reload }

  describe 'model validations' do

    it 'has a valid factory' do
      expect(build(:process_chain)).to be_valid
    end

    expects_to_be_invalid_without :process_chain, :user, :recipe
  end

  describe '#step_classes' do

    before do
      process_chain.update_attribute(:recipe_id, recipe_step.recipe.id)
    end

    it 'returns the step classes' do
      expect(process_chain.step_classes).to eq [InkStep::BasicStep]
    end
  end

  describe '#execute_process!' do
    context "if the chain hasn't been saved yet" do
      it 'fails' do
        new_chain = ProcessChain.new
        expect{new_chain.execute_process!}.to raise_error("Chain not saved yet")
        expect(new_chain.executed_at).to be_nil
      end
    end

    context "if the chain already exists" do

      it 'fails' do
        process_chain.execute_process!

        expect(process_chain.executed_at).to_not be_nil
      end
    end
  end

  describe '#map_results' do
    subject { create(:process_chain) }

    let(:process_step1)    { create(:process_step, process_chain: subject, position: 1, output_file: "nothing") }
    let(:process_step2)    { create(:process_step, process_chain: subject, position: 2, output_file: "nada") }

    let(:some_file)           { File.new('spec/fixtures/files/plaintext.txt') }

    let(:runner_step1)        { double(:process_object, started_at: 10.seconds.ago, finished_at: 5.seconds.ago, errors:[], output_files: some_file, version: "1.2.7", process_step: process_step1) }
    let(:runner_step2)        { double(:process_object, started_at: 4.seconds.ago, finished_at: 2.seconds.ago, errors:["oh noes!"], output_files: nil, version: "0.2.1", process_step: process_step2) }
    let(:runner)              { double(:recipe_process_runner, step_array: [runner_step1, runner_step2]) }

    before do
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

    it 'maps the output files correctly' do
      expect(process_step1.output_file_name).to eq "plaintext.txt"
      expect(process_step2.output_file_name).to eq nil
    end

    it 'maps start times and finishing times correctly' do
      expect(process_step1.started_at.beginning_of_minute).to eq runner_step1.started_at.beginning_of_minute
      expect(process_step1.finished_at.beginning_of_minute).to eq runner_step1.finished_at.beginning_of_minute

      expect(process_step2.started_at.beginning_of_minute).to eq runner_step2.started_at.beginning_of_minute
      expect(process_step2.finished_at.beginning_of_minute).to eq runner_step2.started_at.beginning_of_minute
    end
  end
end