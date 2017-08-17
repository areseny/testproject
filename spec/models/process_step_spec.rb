require 'rails_helper'

RSpec.describe ProcessStep, type: :model do

  describe 'model validations' do

    it 'has a valid factory' do
      expect(build(:process_step)).to be_valid
    end

    expects_to_be_invalid_without :process_step, :process_chain, :position, :step_class_name

    describe 'position' do
      it 'is an integer' do
        expect(build(:process_step, position: 2.4)).to_not be_valid
      end

      it 'is positive' do
        expect(build(:process_step, position: -2)).to_not be_valid
      end

      it 'is greater than 0' do
        expect(build(:process_step, position: 0)).to_not be_valid
      end

      it 'is greater than 0' do
        expect(build(:process_step, position: 1)).to be_valid
      end

      it 'is unique to that recipe / position combination' do
        recipe = create(:process_chain)
        create(:process_step, process_chain: recipe, position: 1)
        expect(build(:process_step, process_chain: recipe, position: 1)).to_not be_valid
      end
    end
  end

  describe '#map_results' do
    let!(:process_chain)      { create(:process_chain) }
    let!(:process_step1)      { create(:process_step, process_chain: process_chain, position: 1) }
    let!(:process_step2)      { create(:process_step, process_chain: process_chain, position: 2) }

    let(:some_file)           { File.new(Rails.root.join('spec/fixtures/files/plaintext.txt')) }

    let(:runner_step1)        { OpenStruct.new(position: 1, successful: true, started_at: 10.seconds.ago, finished_at: 5.seconds.ago, notes: "OK", errors:[], version: "1.2.7", process_log: ["some messages", "#sogreat"], semantically_tagged_manifest: [{path: "abcd"}]) }
    let(:runner_step2)        { OpenStruct.new(position: 2, successful: false, started_at: 4.seconds.ago, finished_at: 2.seconds.ago, notes: "some notes", errors:["oh noes!"], version: "0.2.1", process_log: [], semantically_tagged_manifest: [{path: "abcd"}]) }
    let(:runner)              { double(:recipe_process_runner, step_array: [runner_step1, runner_step2]) }

    before do
      create_directory_if_needed(process_chain.input_files_directory)
      create_directory_if_needed(process_step1.working_directory)
      create_directory_if_needed(process_step2.working_directory)

      process_chain.reload

      process_step1.map_results(behaviour_step: runner_step1)
      process_step2.map_results(behaviour_step: runner_step2)

      process_step1.reload
      process_step2.reload
    end

    it 'maps the version correctly' do
      expect(process_step1.version).to eq "1.2.7"
    end

    it 'maps the version' do
      expect(process_step2.version).to eq "0.2.1"
    end

    it 'maps the errors correctly' do
      expect(process_step1.execution_errors).to eq "[]"
    end

    it 'maps errors' do
      expect(process_step2.execution_errors).to eq "[\"oh noes!\"]"
    end

    it 'maps the notes correctly' do
      expect(process_step1.notes).to eq "[\"OK\"]"
    end

    it 'maps notes' do
      expect(process_step2.notes).to eq "[\"some notes\"]"
    end

    it 'maps start times and finishing times correctly' do
      expect(process_step1.started_at.beginning_of_minute).to eq runner_step1.started_at.beginning_of_minute
      expect(process_step1.finished_at.beginning_of_minute).to eq runner_step1.finished_at.beginning_of_minute
    end

    it 'maps the start and time for step 2' do
      expect(process_step2.started_at.beginning_of_minute).to eq runner_step2.started_at.beginning_of_minute
      expect(process_step2.finished_at.beginning_of_minute).to eq runner_step2.finished_at.beginning_of_minute
    end

    it 'maps the log data for step 1' do
      expect(process_step1.process_log).to eq "[\"some messages\", \"#sogreat\"]"
    end

    it 'maps log for step2' do
      expect(process_step2.process_log).to eq "[]"
    end
  end
end