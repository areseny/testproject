require 'conversion/steps/docx_to_html_xsl'

describe Conversion::Steps::DocxToHtmlXsl do

  let!(:subject)             { Conversion::Steps::DocxToHtmlXsl.new }
  let!(:docx_file_1)         { Rack::Test::UploadedFile.new('spec/fixtures/files/demo.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }
  let!(:docx_file_2)         { Rack::Test::UploadedFile.new('spec/fixtures/files/test-1.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }
  let!(:docx_file_3)         { Rack::Test::UploadedFile.new('spec/fixtures/files/basic_doc.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }
  let!(:xslt_file)           { Rack::Test::UploadedFile.new(subject.xslt_file_path, 'text/xsl') }

  xdescribe 'file conversion step tests' do

    context 'converting a file successfully using DocxToHTML (XSL)' do

      it 'should return a result for the first test document' do
        result = subject.convert_file(docx_file_1)

        expect(result).to_not be_nil
        expect(File.read(result)).to eq ""
        expect(File.read(result)).to_not eq docx_file_1
        expect(File.read(result)).to eq expected_result_1
      end

      it 'should return a result for the second test document' do
        result = subject.convert_file(docx_file_2)

        expect(result).to_not be_nil
        expect(File.read(result)).to eq ""
        expect(File.read(result)).to_not eq docx_file_2
        expect(File.read(result)).to eq expected_result_2
      end


      it 'should return a result for the third test document' do
        result = subject.convert_file(docx_file_3)

        expect(result).to_not be_nil
        expect(File.read(result)).to eq ""
        expect(File.read(result)).to_not eq docx_file_3
        expect(File.read(result)).to eq expected_result_3
      end

    end

  end
end

def expected_result_1
  # StringIO.new("<html>This is a paragraph. Look at it go.</html>")
  "<html>1This is a paragraph. Look at it go.</html>"
end

def expected_result_2
  "<html>2This is a paragraph. Look at it go.</html>"
end

def expected_result_3
  "<html>3This is a paragraph. Look at it go.</html>"
end