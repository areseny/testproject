require 'rails_helper'
require 'rot_thirteen/rot_thirteen_step'

describe RotThirteenStep do

  subject               { RotThirteenStep.new }
  let(:input_file)      { File.new('spec/fixtures/files/some_text.html', 'r') }

  describe 'rot 13' do
    specify do
      subject.required_parameters = []

      expect{subject.perform_step(files: input_file, options: {})}.to_not raise_error
    end
  end
end