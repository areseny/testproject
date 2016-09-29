require 'rails_helper'

describe Conversion::Steps::DownloadAndExecuteXslWithSaxon do

  let!(:subject)              { Conversion::Steps::DownloadAndExecuteXslWithSaxon.new }

  before do
    stub_request(:get, remote_uri).
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => xsl_file, :headers => {})
  end

  def test_result(file:, remote_uri:, result_path:)
    result = subject.convert_file(file.path, remote_xsl_uri: remote_uri)

    expect(result).to_not be_nil
    expect(File.read(result)).to_not eq file
    expect(File.read(result)).to eq File.read(result_path)
  end

  describe 'Xsweet pipeline step 2' do
    let!(:html_file)            { Rack::Test::UploadedFile.new('spec/fixtures/files/xsweet_2_handle_notes_input.html', 'text/html') }
    let(:xsl_file)              { File.read('spec/fixtures/files/xsweet_pipeline/handle-notes.xsl') }
    let(:remote_uri)            { "https://gitlab.coko.foundation/wendell/XSweet/blob/ink-api-publish/handle-notes.xsl" }

    specify do
      test_result(file: html_file, remote_uri: remote_uri, result_path: 'spec/fixtures/files/xsweet_2_handle_notes_result.html')
    end
  end

  describe 'Xsweet pipeline step 3' do
    let!(:html_file)            { Rack::Test::UploadedFile.new('spec/fixtures/files/xsweet_3_scrub_input.html', 'text/html') }
    let(:xsl_file)              { File.read('spec/fixtures/files/xsweet_pipeline/scrub.xsl') }
    let(:remote_uri)            { "https://gitlab.coko.foundation/wendell/XSweet/blob/ink-api-publish/scrub.xsl" }

    specify do
      test_result(file: html_file, remote_uri: remote_uri, result_path: 'spec/fixtures/files/xsweet_3_scrub_result.html')
    end
  end

  describe 'Xsweet pipeline step 4' do
    let!(:html_file)            { Rack::Test::UploadedFile.new('spec/fixtures/files/xsweet_4_join_elements_input.html', 'text/html') }
    let(:xsl_file)              { File.read('spec/fixtures/files/xsweet_pipeline/join-elements.xsl') }
    let(:remote_uri)            { "https://gitlab.coko.foundation/wendell/XSweet/blob/ink-api-publish/join_elements.xsl" }

    specify do
      test_result(file: html_file, remote_uri: remote_uri, result_path: 'spec/fixtures/files/xsweet_4_join_elements_result.html')
    end
  end

  describe 'Xsweet pipeline step 5' do
    let(:html_file)            { Rack::Test::UploadedFile.new('spec/fixtures/files/xsweet_5_zorba_map_input.html', 'text/html') }
    let(:xsl_file)              { File.read('spec/fixtures/files/xsweet_pipeline/zorba-map.xsl') }
    let(:remote_uri)            { "https://gitlab.coko.foundation/wendell/XSweet/blob/ink-api-publish/zorba_map.xsl" }

    specify do
      test_result(file: html_file, remote_uri: remote_uri, result_path: 'spec/fixtures/files/xsweet_5_zorba_map_result.html')
    end
  end
end