require 'rails_helper'

describe base_step_class do

  let(:base_file_location)   { File.join("tmp", "ink_api_files", Time.now.to_i.to_s) }
  subject(:base_step)         { base_step_class.new(base_file_location: base_file_location, position: 1) }
  let(:input_file)            { Rails.root.join('spec/fixtures/files/some_text.html') }
  let(:input_directory)       { File.join(base_file_location, Constants::INPUT_FILE_DIRECTORY_NAME) }

  before do
    create_directory_if_needed(input_directory)
    FileUtils.cp(input_file, input_directory)
  end

  describe 'basic step gem' do
    specify do
      allow(base_step).to receive(:required_parameters).and_return []

      expect{base_step.perform_step}.to_not raise_error
    end
  end
end