require 'rails_helper'

describe Execution::RecipeExecutionRunner do

  let(:text_file)         { File.new(Rails.root.join('spec', 'fixtures', 'files', 'plaintext.txt'), 'r') }

  let!(:chain)          { create(:process_chain) }

  let(:step1)         { create(:process_step, process_chain: chain, position: 1, step_class_name: base_step_class.to_s) }
  let(:step2)         { create(:process_step, process_chain: chain, position: 2, step_class_name: rot_thirteen_step_class.to_s) }


  before do
    chain.initialize_directories
    FileUtils.cp(text_file, chain.input_files_directory)
  end

  describe '#build_pipeline' do
    let(:step_class1)     { base_step_class }
    let(:step_class2)     { rot_thirteen_step_class }
    let!(:step1)          { create(:process_step, process_chain: chain, position: 1, step_class_name: step_class1) }

    context 'with 1 step' do
      let!(:step_hash)    { {1 => step1} }

      subject         { Execution::RecipeExecutionRunner.new(process_step_hash: step_hash, chain_file_location: chain.working_directory, chain_id: chain.id) }

      it 'hooks the steps to each other' do
        result = subject.build_pipeline

        expect(result).to be_a base_step_class
        expect(result.next_step).to eq nil
      end
    end

    context 'with 2 steps' do
      let!(:step1)          { create(:process_step, process_chain: chain, position: 1, step_class_name: base_step_class.to_s) }
      let!(:step2)          { create(:process_step, process_chain: chain, position: 2, step_class_name: rot_thirteen_step_class.to_s) }
      let(:steps)           { {1 => step1, 2 => step2} }

      subject         { Execution::RecipeExecutionRunner.new(process_step_hash: steps, chain_file_location: chain.working_directory, chain_id: chain.id) }

      it 'hooks the steps to each other' do
        result = subject.build_pipeline

        expect(result).to be_a base_step_class
        expect(result.next_step).to be_a rot_thirteen_step_class
        expect(result.next_step.next_step).to eq nil
      end
    end
  end

  describe '#run!' do

    context 'for a successful execution' do

      context 'if there are no steps' do
        subject         { Execution::RecipeExecutionRunner.new(process_step_hash: {}, chain_file_location: chain.working_directory, chain_id: chain.id) }

        it 'returns nil - no change was made' do
          result = subject.run!

          expect(result).to eq nil
        end
      end

      context 'if there is 1 step' do
        let!(:step1)          { create(:process_step, process_chain: chain, position: 1, step_class_name: base_step_class.to_s) }

        subject               { Execution::RecipeExecutionRunner.new(process_step_hash: {1 => step1}, chain_file_location: chain.working_directory, chain_id: chain.id) }

        it 'returns a result' do
          result = subject.run!

          expect(result).to be_a base_step_class
          expect(result.started_at).to_not be_nil
          expect(result.finished_at).to_not be_nil
        end
      end

      context 'if there are 3 steps' do
        let!(:step1)          { create(:process_step, process_chain: chain, position: 1, step_class_name: base_step_class.to_s) }
        let!(:step2)          { create(:process_step, process_chain: chain, position: 2, step_class_name: rot_thirteen_step_class.to_s) }
        let!(:step3)          { create(:process_step, process_chain: chain, position: 3, step_class_name: base_step_class.to_s) }
        let(:steps)           { {1 => step1, 2 => step2, 3 => step3} }
        subject               { Execution::RecipeExecutionRunner.new(process_step_hash: steps, chain_file_location: chain.working_directory, chain_id: chain.id) }

        it 'returns a result' do
          result = subject.run!

          expect(result).to be_a base_step_class
        end
      end
    end

    context 'if there is a failure' do
      let(:steps)               { {1 => step1} }
      subject                   { Execution::RecipeExecutionRunner.new(process_step_hash: steps, chain_file_location: chain.working_directory, chain_id: chain.id) }

      before do
        allow_any_instance_of(base_step_class).to receive(:perform_step) { raise "Oh noes! Error!" }
      end

      it 'the step does not have an output file' do
        result = subject.run!
        chain.reload
        ap chain

        expect(result).to be_a base_step_class
        expect(chain.output_file_manifest).to eq [{:path=>"plaintext.txt", :size=>"18 bytes"}]
      end

      it 'logs the error' do
        result = subject.run!

        expect(result.errors).to eq ["Oh noes! Error!"]
      end

    end
  end
end