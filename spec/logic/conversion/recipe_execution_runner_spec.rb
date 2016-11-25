require 'rails_helper'

describe Execution::RecipeExecutionRunner do

  let!(:text_file)         { File.new('spec/fixtures/files/plaintext.txt', 'r') }
  let!(:photo_file)        { File.new('spec/fixtures/files/kitty.jpeg', 'r') }

  let(:step1)         { create(:process_step, step_class_name: "InkStep::BasicStep") }
  let(:step2)         { create(:process_step, step_class_name: "RotThirteenStep") }

  describe '#build_chain' do
    let(:step_class1)    { InkStep::BasicStep}
    let(:step_class2)    { RotThirteenStep }

    context 'with 1 step' do
      let!(:steps)    { [step1] }

      subject         { Execution::RecipeExecutionRunner.new(steps) }

      it 'hooks the steps to each other' do
        result = subject.build_chain

        expect(result).to be_a InkStep::BasicStep
        expect(result.next_step).to eq nil
      end
    end

    context 'with 2 steps' do
      let(:steps)       { [step1, step2] }

      subject         { Execution::RecipeExecutionRunner.new(steps) }

      it 'hooks the steps to each other' do
        result = subject.build_chain

        expect(result).to be_a InkStep::BasicStep
        expect(result.next_step).to be_a RotThirteenStep
        expect(result.next_step.next_step).to eq nil
      end
    end
  end

  describe '#execute' do

    context 'for a successful execution' do

      context 'if there are no steps' do
        subject         { Execution::RecipeExecutionRunner.new([]) }

        it 'returns nil - no change was made' do
          result = subject.run!(files: photo_file)

          expect(result).to eq nil
        end
      end

      context 'if there is 1 step' do
        let!(:steps)    { [step1] }
        subject         { Execution::RecipeExecutionRunner.new(steps) }

        it 'returns a result' do
          result = subject.run!(files: photo_file)

          expect(result).to be_a InkStep::BasicStep
          expect(result.output_files).to eq photo_file
        end
      end

      context 'if there are 3 steps' do
        let(:step3)     { create(:process_step, step_class_name: "InkStep::BasicStep") }
        let(:steps)     { [step1, step2, step3] }
        subject         { Execution::RecipeExecutionRunner.new(steps) }

        it 'returns a result' do
          result = subject.run!(files: photo_file)

          expect(result).to be_a InkStep::BasicStep
          expect(result.output_files).to eq photo_file
        end
      end
    end

    context 'if there is a failure' do
      let(:steps)              { [step1] }
      let(:boobytrapped_step)  { InkStep::BasicStep.new(process_step: step1) }

      before do
        expect(boobytrapped_step).to receive(:perform_step) { raise "OMG!" }
        expect(InkStep::BasicStep).to receive(:new).and_return boobytrapped_step
      end

      it 'the step does not have an output file' do
        subject = Execution::RecipeExecutionRunner.new(steps)
        result = subject.run!(files: text_file)

        expect(result).to be_a InkStep::BasicStep
        expect(result.output_files).to eq nil
      end

      it 'logs the error' do
        subject = Execution::RecipeExecutionRunner.new(steps)
        result = subject.run!(files: text_file)

        expect(result.errors).to eq ["OMG!"]
      end

    end
  end
end