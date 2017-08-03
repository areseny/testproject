require 'rails_helper'

describe Execution::RecipeExecutionRunner do

  let(:text_file)         { File.new(Rails.root.join('spec', 'fixtures', 'files', 'plaintext.txt'), 'r') }

  let!(:chain)          { create(:process_chain) }

  let(:step1)         { create(:process_step, process_chain: chain, position: 1, step_class_name: base_step_class.to_s) }
  let(:step2)         { create(:process_step, process_chain: chain, position: 2, step_class_name: rot_thirteen_step_class.to_s) }
  let(:error_message) { /Process steps are empty for chain \d+/ }

  before do
    chain.initialize_directories
    FileUtils.cp(text_file, chain.input_files_directory)
  end

  describe '#run!' do
    context 'for a successful execution' do
      context 'if there are no steps' do
        subject         { Execution::RecipeExecutionRunner.new(process_steps_in_order: [], chain_file_location: chain.working_directory, process_chain: chain) }

        it 'returns nil - no change was made' do
          expect{subject.run!}.to raise_error(ExecutionErrors::EmptyChainError, error_message)
        end
      end

      context 'if there is 1 step' do
        let!(:step1)          { create(:process_step, process_chain: chain, position: 1, step_class_name: base_step_class.to_s) }

        subject               { Execution::RecipeExecutionRunner.new(process_steps_in_order: [step1], chain_file_location: chain.working_directory, process_chain: chain) }

        before { chain.reload }

        it 'returns a result' do
          subject.run!

          expect(subject.step_array[0].started_at).to_not be_nil
          expect(subject.step_array[0].finished_at).to_not be_nil
        end
      end

      context 'if there are 3 steps' do
        let!(:step1)          { create(:process_step, process_chain: chain, position: 1, step_class_name: base_step_class.to_s) }
        let!(:step2)          { create(:process_step, process_chain: chain, position: 2, step_class_name: rot_thirteen_step_class.to_s) }
        let!(:step3)          { create(:process_step, process_chain: chain, position: 3, step_class_name: base_step_class.to_s) }
        let(:steps)           { [step1, step2, step3] }
        subject               { Execution::RecipeExecutionRunner.new(process_steps_in_order: steps, chain_file_location: chain.working_directory, process_chain: chain) }

        before { chain.reload }

        it 'returns a result' do
          subject.run!

          expect(subject.step_array[0]).to be_a base_step_class
          expect(subject.step_array[1]).to be_a rot_thirteen_step_class
          expect(subject.step_array[2]).to be_a base_step_class
        end
      end
    end

    context 'if there is a failure' do
      let(:steps)               { [step1] }
      subject                   { Execution::RecipeExecutionRunner.new(process_steps_in_order: steps, chain_file_location: chain.working_directory, process_chain: chain) }

      before do
        allow_any_instance_of(base_step_class).to receive(:perform_step) { raise "Oh noes! Error!" }
        chain.reload
      end

      it 'logs the error' do
        expect{subject.run!}.to raise_error

        expect(subject.step_array[0].errors).to eq ["Oh noes! Error!"]
      end

      it 'raises the exception' do
        expect{subject.run!}.to raise_error
      end
    end
  end

  describe '#semantically_tagged_manifest' do
    subject             { Execution::RecipeExecutionRunner.new(process_steps_in_order: [step1], chain_file_location: chain.working_directory, process_chain: chain) }

    let(:file_manifest) {
      [{
           :path => "a_file.docx",
           :size => "5.3 kB",
           :checksum => "f2447e0904f3f3b84c8b1e710fabfce1"
       },
       {
           :path => "another_file.docx",
           :size => "2.8 kB",
           :checksum => "111017ee94636df62daa98257cc1bfeb"
       }]
    }

    context 'a file has been added' do
      let(:old_file_manifest) {
        [{
             :path => "a_file.docx",
             :size => "5.3 kB",
             :checksum => "f2447e0904f3f3b84c8b1e710fabfce1"
         }]
      }

      let(:expected_result) {
        [{
             path: "a_file.docx",
             size: "5.3 kB",
             checksum: "f2447e0904f3f3b84c8b1e710fabfce1",
             tag: :identical
         },
         {
             path: "another_file.docx",
             size: "2.8 kB",
             checksum: "111017ee94636df62daa98257cc1bfeb",
             tag: :new
         }]
      }

      before do
        allow(subject).to receive(:assemble_manifest).and_return(file_manifest)
      end

      it 'marks that it has been added' do
        expect(subject.semantically_tagged_manifest(step1.working_directory, old_file_manifest)).to match expected_result
      end
    end

    context 'a file has been modified' do
      let(:old_file_manifest) {
        [{
             :path => "a_file.docx",
             :size => "2.8 kB",
             :checksum => "hahahhahaahahahahahahahahahahah"
         }]
      }

      let(:expected_result) {
        [{
             path: "a_file.docx",
             size: "5.3 kB",
             checksum: "f2447e0904f3f3b84c8b1e710fabfce1",
             tag: :modified
         },
         {
             :path => "another_file.docx",
             :size => "2.8 kB",
             :checksum => "111017ee94636df62daa98257cc1bfeb",
             tag: :new
         }
        ]
      }

      before do
        allow(subject).to receive(:assemble_manifest).and_return(file_manifest)
      end

      it 'marks that it has been added' do
        expect(subject.semantically_tagged_manifest(step1.working_directory, old_file_manifest)).to eq expected_result
      end
    end
  end
end