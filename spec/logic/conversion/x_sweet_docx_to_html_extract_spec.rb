require 'rails_helper'

describe Conversion::Steps::XSweetDocxToHtmlExtract do

  let!(:subject)              { Conversion::Steps::XSweetDocxToHtmlExtract.new }
  let!(:docx_file_1)          { Rack::Test::UploadedFile.new('spec/fixtures/files/basic_doc.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }
  let(:xsl_file)             { File.read('spec/fixtures/files/xsweet_pipeline/docx-html-extract.xsl') }

  before do
    stub_request(:get, "https://gitlab.coko.foundation/wendell/XSweet/blob/ink-api-publish/docx-html-extract.xsl").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => xsl_file, :headers => {})
  end

  describe 'Xsweet pipeline step 1' do
    it 'should return a result for the first test document' do
      result = subject.convert_file(docx_file_1.path)

      expect(result).to_not be_nil
      expect(File.read(result)).to_not eq docx_file_1
      expect(File.read(result)).to eq File.read('spec/fixtures/files/xsweet_1_extract_result.html')
    end
  end
end