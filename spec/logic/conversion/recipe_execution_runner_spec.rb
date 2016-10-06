require 'rails_helper'

describe Conversion::RecipeExecutionRunner do

  let!(:text_file)         { File.new('spec/fixtures/files/plaintext.txt', 'r') }
  let!(:photo_file)        { File.new('spec/fixtures/files/kitty.jpeg', 'r') }

  describe '#build_chain' do
    let!(:step1)    { InkStep::BasicStep}
    let!(:step2)    { RotThirteenStep }

    context 'with 1 step' do
      let!(:steps)    { [step1] }

      subject         { Conversion::RecipeExecutionRunner.new(steps) }

      it 'should hook the steps to each other' do
        result = subject.build_chain

        expect(result).to be_a step1
        expect(result.next_step).to eq nil
      end
    end

    context 'with 2 steps' do
      let!(:steps)    { [step1, step2] }

      subject         { Conversion::RecipeExecutionRunner.new(steps) }

      it 'should hook the steps to each other' do
        result = subject.build_chain

        expect(result).to be_a step1
        expect(result.next_step).to be_a step2
        expect(result.next_step.next_step).to eq nil
      end
    end
  end

  describe '#execute' do

    context 'for a successful conversion' do

      context 'if there are no steps' do
        subject         { Conversion::RecipeExecutionRunner.new([]) }

        it 'should return nil - no change was made' do
          result = subject.run!(photo_file)

          expect(result).to eq nil
        end
      end

      context 'if there is 1 step' do
        let!(:steps)    { [InkStep::BasicStep] }
        subject         { Conversion::RecipeExecutionRunner.new(steps) }

        it 'should return a result' do
          result = subject.run!(photo_file)

          expect(result).to be_a InkStep::BasicStep
          expect(result.output_files).to eq photo_file
        end
      end

      context 'if there are 3 steps' do
        let!(:steps)    { [InkStep::BasicStep, InkStep::BasicStep, InkStep::BasicStep] }
        subject         { Conversion::RecipeExecutionRunner.new(steps) }

        it 'should return a result' do
          result = subject.run!(photo_file)

          expect(result).to be_a InkStep::BasicStep
          expect(result.output_files).to eq photo_file
        end
      end
    end

    context 'if there is a failure' do
      let!(:steps)              { [InkStep::BasicStep] }
      let!(:boobytrapped_step)  { InkStep::BasicStep.new }

      before do
        expect(boobytrapped_step).to receive(:perform_step) { raise "OMG!" }
        expect(InkStep::BasicStep).to receive(:new).and_return boobytrapped_step
      end

      it 'the step should not have an output file' do
        subject = Conversion::RecipeExecutionRunner.new(steps)
        result = subject.run!(text_file)

        expect(result).to be_a InkStep::BasicStep
        expect(result.output_files).to eq nil
      end

      it 'should log the error' do
        subject = Conversion::RecipeExecutionRunner.new(steps)
        result = subject.run!(text_file)

        expect(result.errors).to eq ["OMG!"]
      end

    end
  end
end