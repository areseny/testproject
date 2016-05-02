require 'conversion/steps/docx_to_html'

describe Conversion::Steps::DocxToHtml do

  let!(:subject)           { Conversion::Steps::DocxToHtml.new }
  let!(:docx_file)         { Rack::Test::UploadedFile.new('spec/fixtures/files/demo.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }
  # let!(:expected_result)   { Rack::Test::UploadedFile.new('spec/fixtures/files/docx_to_html_test_file.html', 'text/html') }
  let!(:xslt_file)         { Rack::Test::UploadedFile.new(subject.xslt_file_path, 'text/xsl') }

  describe '#convert_file' do

    context 'with the correct file type' do

      it 'should return a result' do
        result = subject.convert_file(docx_file)

        expect(result.output_files).to_not be_nil
        expect(result.output_files).to_not eq docx_file
        expect(result.output_file).to eq expected_result
      end

      context 'the conversion call has an error' do
        before do
          allow(subject).to receive(:output_file_path).and_return("NOWHERE")
          allow(subject).to receive(:system).and_return("thing")
        end

        it 'should return the error' do
          expect{subject.convert_file(docx_file)}.to raise_error("thing")
        end

      end

    end

  end
end

def expected_result
  StringIO.new("<html>This is a paragraph. Look at it go.</html>")
end