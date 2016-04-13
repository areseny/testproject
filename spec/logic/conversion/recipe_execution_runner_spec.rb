require 'conversion/recipe_execution_runner'

describe Conversion::RecipeExecutionRunner do


  let!(:xml_file)         { Rack::Test::UploadedFile.new('spec/fixtures/files/test_file.xml', 'text/xml') }
  let!(:xslt_file)        { Rack::Test::UploadedFile.new('spec/fixtures/files/xml_to_html_transform.html.xslt.haml', 'text/xsl') }
  let!(:photo_file)       { Rack::Test::UploadedFile.new('spec/fixtures/files/kitty.jpeg', 'image/jpeg') }

  describe '#build_chain' do

    let!(:step1)    { Conversion::Steps::XmlToHtml }
    let!(:step2)    { Conversion::Steps::JpgToPng }
    let!(:steps)    { [step1, step2] }

    subject         { Conversion::RecipeExecutionRunner.new(steps) }

    it 'should hook the steps to each other' do
      result = subject.build_chain

      expect(result).to be_a step1
      expect(result.next_step).to be_a step2
      expect(result.next_step.next_step).to eq nil
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
        let!(:steps)    { [Conversion::Steps::Step] }
        subject         { Conversion::RecipeExecutionRunner.new(steps) }

        it 'should return a result' do
          result = subject.run!(photo_file)

          expect(result).to be_a Conversion::Steps::Step
          expect(result.output_files).to eq photo_file
        end
      end

      context 'if there are 3 steps' do
        let!(:steps)    { [Conversion::Steps::Step, Conversion::Steps::Step, Conversion::Steps::JpgToPng] }
        subject         { Conversion::RecipeExecutionRunner.new(steps) }

        it 'should return a result' do
          result = subject.run!(photo_file)

          expect(result).to be_a Conversion::Steps::Step
          expect(result.output_files).to eq photo_file
        end
      end
    end

    context 'if there is a failure' do
      let!(:steps)              { [Conversion::Steps::JpgToPng] }
      let!(:boobytrapped_step)  { Conversion::Steps::JpgToPng.new }

      before do
        expect(boobytrapped_step).to receive(:convert_file) { raise "OMG!" }
        expect(Conversion::Steps::JpgToPng).to receive(:new).and_return boobytrapped_step
      end

      it 'the step should not have an output file' do
        subject = Conversion::RecipeExecutionRunner.new(steps)
        result = subject.run!(xml_file)

        expect(result).to be_a Conversion::Steps::Step
        expect(result.output_files).to eq nil
      end

      it 'should log the error' do
        subject = Conversion::RecipeExecutionRunner.new(steps)
        result = subject.run!(xml_file)

        expect(result.errors).to eq ["OMG!"]
      end

    end
  end
end