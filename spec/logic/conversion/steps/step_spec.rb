require 'rails_helper'

describe InkStep::BasicStep do

  subject               { InkStep::BasicStep.new }
  let(:input_file)      { File.new('spec/fixtures/files/some_text.html', 'r') }

  describe 'basic step gem' do
    specify do
      subject.required_parameters = []

      expect{subject.perform_step(files: input_file, options: {})}.to_not raise_error
    end
  end
end