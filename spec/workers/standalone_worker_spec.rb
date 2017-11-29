require 'rails_helper'

describe StandaloneExecutionWorker do

  subject(:worker)  { StandaloneExecutionWorker.new }
  let(:execution)   { create(:single_step_execution) }

  let(:file_location)                 { File.join("tmp", "ink_api_files", Time.now.to_i.to_s) }
  let(:valid_klass_file)              { Rails.root.join('spec/fixtures/files/standalone/awesome_class.rb') }
  let(:valid_klass_file_with_return)  { Rails.root.join('spec/fixtures/files/standalone/awesome_class_with_return.rb') }
  let(:invalid_klass_file)            { Rails.root.join('spec/fixtures/files/standalone/rubbish_class') }
  let(:valid_not_a_class_file)        { Rails.root.join('spec/fixtures/files/standalone/valid_not_a_class.rb') }
  let(:nonexistent_file)              { Rails.root.join('spec/fixtures/files/standalone/lol.rb') }
  let(:input_file)                    { Rails.root.join('spec/fixtures/files/some_text.html') }
  let(:input_directory)               { File.join(file_location, Constants::INPUT_FILE_DIRECTORY_NAME) }

  before do
    worker.instance_variable_set(:@single_step_execution, execution)
    create_directory_if_needed(input_directory)
    create_directory_if_needed(execution.working_directory)
    FileUtils.cp(input_file, file_location)
  end

  describe '#load_klass' do

    context 'the file exists' do
      context 'the class is returned at the bottom of the file' do
        before do
          allow(execution).to receive(:code_file_location).and_return(valid_klass_file_with_return)
          execution.update_attribute(:step_class_name, "InkStep::AwesomeClass")
        end

        it 'loads the file properly' do
          expect(worker.load_klass).to eq InkStep::AwesomeClass
        end
      end

      context 'the class needs to rely on the given class name' do
        before do
          allow(execution).to receive(:code_file_location).and_return(valid_klass_file)
          execution.update_attribute(:step_class_name, "InkStep::AwesomeClass")
        end

        it 'loads the file properly' do
          expect(worker.load_klass).to eq InkStep::AwesomeClass
        end
      end

    end

    context 'the file does not exist' do

      before do
        allow(execution).to receive(:code_file_location).and_return(nonexistent_file)
        execution.update_attribute(:step_class_name, "InkStep::NonexistentClass")
      end

      it 'does not load' do
        expect{worker.load_klass}.to raise_error(Errno::ENOENT, /No such file or directory/)
      end
    end

    context 'the file is improperly formatted' do
      before do
        allow(execution).to receive(:code_file_location).and_return(invalid_klass_file)
        execution.update_attribute(:step_class_name, "InkStep::RubbishClass")
      end

      it 'does not load' do
        expect{worker.load_klass}.to raise_error(ExecutionErrors::ClassInvalidError, /Syntax error/)
      end
    end

    context 'the file class is valid but does not match the name' do
      context 'with return' do
        before do
          allow(execution).to receive(:code_file_location).and_return(valid_klass_file_with_return)
          execution.update_attribute(:step_class_name, "InkStep::TypoClass")
        end

        it 'does not load even with a returned class name' do
          expect{worker.load_klass}.to raise_error(ExecutionErrors::ClassNotDefinedError, /Mismatch/)
        end

      end

      context 'without return' do

        before do
          allow(execution).to receive(:code_file_location).and_return(valid_klass_file)
          execution.update_attribute(:step_class_name, "InkStep::TypoClass")
        end

        it 'does not load' do
          expect{worker.load_klass}.to raise_error(ExecutionErrors::ClassNotDefinedError, /Mismatch/)
        end
      end
    end

    context 'the file is valid but does not contain a class' do
      before do
        FileUtils.cp(valid_not_a_class_file, execution.working_directory)
      end
    end
  end
end