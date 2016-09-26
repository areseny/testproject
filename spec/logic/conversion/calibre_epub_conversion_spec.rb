require 'rails_helper'

describe Conversion::Steps::EpubCalibre do

  # let!(:subject)            { Conversion::Steps::EpubCalibre.new }
  let!(:html_file)          { Rack::Test::UploadedFile.new('spec/fixtures/files/test.html', 'text/html') }
  let!(:html_file)          { fixture_file_upload('files/test.html', 'text/html') }

  describe 'file conversion step tests' do

    context 'converting a file successfully using EpubCalibre' do

      specify do
        # necessary because calibre is picky about file extension!
        the_file = File.read(html_file.path)
        File.write('tmp/test.html', the_file)

        result = subject.convert_file(File.new('tmp/test.html'))

        expect(result).to_not be_nil
        expect(File.extname(result)).to eq ".epub"
      end
    end
  end
end