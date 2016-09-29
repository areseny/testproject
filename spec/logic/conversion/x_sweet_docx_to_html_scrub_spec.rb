require 'rails_helper'

describe Conversion::Steps::XSweetDocxToHtmlScrub do

  let!(:subject)              { Conversion::Steps::XSweetDocxToHtmlScrub.new }
  let!(:html_file)            { Rack::Test::UploadedFile.new('spec/fixtures/files/xsweet_3_scrub_input.html', 'text/html') }
  let!(:xslt_zip)             { File.read('spec/fixtures/files/XSweet-ink-api-publish-4da80d4ed5fc420897d63932febd696b03082ed6.zip') }

  before do
    stub_request(:get, "https://gitlab.coko.foundation/wendell/XSweet/repository/archive.zip?ref=ink-api-publish").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => xslt_zip, :headers => {})
  end

  describe 'Xsweet pipeline step 3' do
    it 'should return a result for the first test document' do
      result = subject.convert_file(html_file.path)

      expect(result).to_not be_nil
      expect(File.read(result)).to_not eq html_file
      expect(File.read(result)).to eq File.read('spec/fixtures/files/xsweet_3_scrub_result.html')
    end
  end
end