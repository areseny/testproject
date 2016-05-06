require 'conversion/steps/docx_to_html'

describe Conversion::Steps::DocxToHtml do

  let!(:subject)             { Conversion::Steps::DocxToHtml.new }
  let!(:docx_file_1)         { Rack::Test::UploadedFile.new('spec/fixtures/files/demo.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }
  let!(:docx_file_2)         { Rack::Test::UploadedFile.new('spec/fixtures/files/test-1.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }
  let!(:docx_file_3)         { Rack::Test::UploadedFile.new('spec/fixtures/files/basic_doc.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }
  let!(:xslt_file)           { Rack::Test::UploadedFile.new(subject.xslt_file_path, 'text/xsl') }

  describe '#convert_file' do

    context 'with the correct file type' do

      it 'should return a result for the first test document' do
        result = subject.convert_file(docx_file_1)

        expect(result).to_not be_nil
        expect(result).to_not eq docx_file_1
        expect(result).to eq expected_result_1
      end

      it 'should return a result for the second test document' do
        result = subject.convert_file(docx_file_2)

        expect(result).to_not be_nil
        expect(result).to_not eq docx_file_2
        expect(result).to eq expected_result_2
      end


      it 'should return a result for the third test document' do
        result = subject.convert_file(docx_file_3)

        expect(result).to_not be_nil
        expect(result).to_not eq docx_file_3
        expect(result).to eq expected_result_3
      end

      context 'the conversion call has an error' do
        before do
          allow(subject).to receive(:output_file_path).and_return("NOWHERE")
          allow(subject).to receive(:system).and_return("thing")
        end

        it 'should return the error' do
          expect{subject.convert_file(docx_file_1)}.to raise_error("thing")
        end

      end

    end

  end
end

def expected_result_1
  StringIO.new("<html>This is a paragraph. Look at it go.</html>")
end

def expected_result_2
  StringIO.new("<html>This is a paragraph. Look at it go.</html>")
end

def expected_result_3
  StringIO.new("<html>This is a paragraph. Look at it go.</html>")
end