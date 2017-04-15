require 'rails_helper'
require_relative '../version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe "Executing a recipe and making sure all the files get put in the right place" do

  let!(:account)             { create(:account) }
  let!(:demo_step)        { base_step_class.to_s }
  let!(:recipe)           { create(:recipe, account: account, step_classes: [demo_step]) }

  let!(:file_path)        { Rails.root.join("spec", "fixtures", "files", "test_file.xml") }
  let!(:file_contents)    { File.open(file_path) }
  let!(:file)             { ActionDispatch::Http::UploadedFile.new(tempfile: file_path, filename: File.basename(file_path), type: "text/xml") }

  before do
    recipe.reload
    recipe.clone_and_execute(input_files: file, account: account, callback_url: "")
  end

  it 'creates the proper folder in the filesystem for the chain' do
    process_chain = recipe.process_chains.last

    input_file_directory = File.join(Constants::FILE_LOCATION, process_chain.slug, Constants::INPUT_FILE_DIRECTORY_NAME)

    expect(File.directory?(input_file_directory)).to be_truthy
  end

  it 'places the input file into the right folder' do
    process_chain = recipe.process_chains.last

    expect(process_chain.input_file_manifest).to match([{:path=>"test_file.xml", :size=>"110 bytes"}])
  end

  it 'creates the proper folder in the filesystem for the steps' do
    process_chain = recipe.process_chains.last

    Dir.chdir(process_chain.working_directory)
    step_directory_list = Dir.glob('*').select{ |f| File.directory?(f)}

    expect(step_directory_list).to contain_exactly("1", Constants::INPUT_FILE_DIRECTORY_NAME)
  end

  it 'ensures the step output files are in the right place' do
    process_chain = recipe.process_chains.last

    process_step = process_chain.process_steps.last # and only!

    Dir.chdir(process_step.working_directory)
    step_file_list = Dir.glob('*').select {|f| File.file? f}

    expect(step_file_list).to contain_exactly("test_file.xml")
  end
end