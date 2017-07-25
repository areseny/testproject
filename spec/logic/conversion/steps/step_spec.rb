require 'rails_helper'

describe base_step_class do

  let(:chain_file_location)   { File.join("tmp", "ink_api_files", Time.now.to_i.to_s) }
  subject                     { base_step_class.new(chain_file_location: chain_file_location, position: 1) }
  let(:input_file)            { File.new('spec/fixtures/files/some_text.html', 'r') }

  describe 'basic step gem' do
    specify do
      allow(subject).to receive(:required_parameters).and_return []

      expect{subject.perform_step(options: {})}.to_not raise_error
    end
  end
end