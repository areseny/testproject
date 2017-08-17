require 'rails_helper'
require_relative '../version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe "Account executes a ROT13 recipe" do

  # URL: /api/recipes/:id/execute
  # Method: GET
  # Execute a specific recipe belonging to the current account

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: account@example.com, auth_token: asdf" -X GET http://localhost:3000/api/recipes/:id/execute

  let!(:account)          { create(:account, password: "password", password_confirmation: "password") }
  let!(:auth_headers)     { account.new_jwt }
  let!(:text_file)        { fixture_file_upload('files/plaintext.txt', 'text/plain') }

  let!(:step_class)       { rot_thirteen_step_class.to_s }

  let!(:recipe)           { create(:recipe, account: account, step_classes: [step_class]) }

  let!(:step1)            { recipe.recipe_steps.first }

  let!(:execution_params) {
    {
        input_files: text_file,
        id: recipe.id
    }
  }

  context 'if the execution is successful' do
    before do
      perform_execute_request(auth_headers, execution_params)
    end

    it 'is successful' do
      expect(response.status).to eq(200)
      expect(body_as_json['process_chain']).to_not be_nil
      expect(body_as_json['process_chain']['process_steps'].count).to eq 1
      body_as_json['process_chain']['process_steps'].map do |s|
        expect(s['execution_errors']).to eq ""
      end
      # expect(body_as_json['process_chain']['process_steps'].sort_by{|e| e['position'].to_i}.map{|e| e['output_file_path']}).to eq [true, true]
    end

    it 'has an expected output file' do
      process_chain = ProcessChain.last
      result = process_chain.output_file_manifest.last[:path]
      result_path = File.join(process_chain.process_steps.last.send(:working_directory), result)

      expect(File.new(result_path).read).to eq "Guvf vf fbzr grkg."
    end
  end

  context 'if the execution fails' do
    before do
      allow_any_instance_of(rot_thirteen_step_class).to receive(:cumulative_file_manifest).and_return({input: [{:path=>"plaintext.txt", :size=>"18 bytes", checksum: "5a42e1f277fbc664677c2d290742176b"}]})
      allow_any_instance_of(rot_thirteen_step_class).to receive(:perform_step) { raise "OMG!" }
    end

    it 'still has files' do
      perform_execute_request(auth_headers, execution_params)

      result = ProcessChain.last.output_file_manifest
      expect(result).to match([{:path=>"plaintext.txt", :size=>"18 bytes", checksum: "5a42e1f277fbc664677c2d290742176b", tag: :identical}])
    end
  end

  def perform_execute_request(auth_headers, data)
    execute_recipe_request(version, auth_headers, data)
  end
end