require 'rails_helper'

describe Conversion::Steps::Step do

  subject               { Conversion::Steps::Step.new }
  let(:input_file)      { OpenStruct.new(blah: "hi") }

  before do
    allow(subject).to receive(:input_filename).and_return("a file")
  end

  describe 'required parameters' do
    context 'when there are no required parameters' do
      specify do
        subject.required_parameters = []

        expect{subject.convert_file(input_file, options_hash = {})}.to_not raise_error
        expect{subject.convert_file(input_file, options_hash = {other_param: "some_value"})}.to_not raise_error
      end

    end

    context 'when there are required parameters' do
      context 'and they are satisfied' do
        specify do
          subject.required_parameters = [:fancy_param]

          expect{subject.convert_file(input_file, fancy_param: "funny hats")}.to_not raise_error
        end
      end

      context 'and they are not satisfied' do
        specify do
          subject.required_parameters = [:fancy_param, :silly_param]

          expect{subject.convert_file(input_file)}.to raise_error("Missing parameters: fancy_param, silly_param")
          expect{subject.convert_file(input_file, {other_param: "some_value"})}.to raise_error("Missing parameters: fancy_param, silly_param")
        end
      end
    end
  end
end