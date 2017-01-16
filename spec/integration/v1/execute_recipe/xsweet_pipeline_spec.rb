require 'rails_helper'
require_relative '../version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe "User executes a recipe xsweet pipeline" do

  # URL: /api/recipes/:id/execute
  # Method: POST
  # Execute a specific recipe belonging to the current user

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X POST --form "input_files=[@my-file.txt], callback_url=mysite.com/callback" http://localhost:3000/api/recipes/:id/execute

  describe "POST execute recipe" do

    let!(:user)             { create(:user, password: "password", password_confirmation: "password") }
    let!(:auth_headers)     { user.create_new_auth_token }
    let!(:docx_file)        { fixture_file_upload('files/SampleStyles.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }

    let!(:recipe)           { create(:recipe, user: user, step_classes: [extract1, notes2, scrub3, join4, zorba5]) }

    let!(:execution_params) {
      {
          input_files: docx_file,
          id: recipe.id
      }
    }

    let!(:extract1)   { xsweet_step_1_extract_step_class.to_s }
    let!(:notes2)     { xsweet_step_2_notes_step_class.to_s }
    let!(:scrub3)     { xsweet_step_3_scrub_step_class.to_s }
    let!(:join4)      { xsweet_step_4_join_step_class.to_s }
    let!(:zorba5)     { xsweet_step_5_zorba_step_class.to_s }

    let(:step_1_xsl_file)             { File.read(Rails.root.join('spec/fixtures/files/xsweet_pipeline/docx-html-extract.xsl')) }
    let(:step_1_remote_uri)           { "https://gitlab.coko.foundation/wendell/XSweet/raw/ink-api-publish/docx-html-extract.xsl" }
    let(:step_2_xsl_file)             { File.read(Rails.root.join('spec/fixtures/files/xsweet_pipeline/handle-notes.xsl')) }
    let(:step_2_remote_uri)           { "https://gitlab.coko.foundation/wendell/XSweet/raw/ink-api-publish/handle-notes.xsl" }
    let(:step_3_xsl_file)             { File.read(Rails.root.join('spec/fixtures/files/xsweet_pipeline/scrub.xsl')) }
    let(:step_3_remote_uri)           { "https://gitlab.coko.foundation/wendell/XSweet/raw/ink-api-publish/scrub.xsl" }
    let(:step_4_xsl_file)             { File.read(Rails.root.join('spec/fixtures/files/xsweet_pipeline/join-elements.xsl')) }
    let(:step_4_remote_uri)           { "https://gitlab.coko.foundation/wendell/XSweet/raw/ink-api-publish/join-elements.xsl" }
    let(:step_5_xsl_file)             { File.read(Rails.root.join('spec/fixtures/files/xsweet_pipeline/zorba-map.xsl')) }
    let(:step_5_remote_uri)           { "https://gitlab.coko.foundation/wendell/XSweet/raw/ink-api-publish/zorba-map.xsl" }

    before do
      stub_xsl_download(step_1_remote_uri, step_1_xsl_file)
      stub_xsl_download(step_2_remote_uri, step_2_xsl_file)
      stub_xsl_download(step_3_remote_uri, step_3_xsl_file)
      stub_xsl_download(step_4_remote_uri, step_4_xsl_file)
      stub_xsl_download(step_5_remote_uri, step_5_xsl_file)
    end

    context 'and execution is successful' do
      it 'returns the objects' do
        perform_execute_request(auth_headers, execution_params)

        expect(response.status).to eq(200)
        expect(body_as_json['process_chain']['successful'])
        expect(body_as_json['process_chain']['process_steps'].count).to eq 5
        body_as_json['process_chain']['process_steps'].map do |s|
          expect(s['execution_errors']).to eq ""
        end
      end

      it 'returns a ProcessChain object' do
        perform_execute_request(auth_headers, execution_params)

        process_chain = recipe.reload.process_chains.first

        expect(body_as_json['process_chain']['recipe_id']).to eq process_chain.recipe_id
        expect(body_as_json['process_chain']['executed_at']).to eq process_chain.executed_at.iso8601
        expect(body_as_json['process_chain']['finished_at']).to_not be_nil
        expect(body_as_json['process_chain']['input_file_manifest']).to match(process_chain.input_file_manifest.map(&:stringify_keys))
        expect(body_as_json['process_chain']['output_file_manifest']).to match(process_chain.output_file_manifest.map(&:stringify_keys))
      end

      it 'also returns the steps' do
        perform_execute_request(auth_headers, execution_params)

        expect(body_as_json['process_chain']['process_steps'].count).to eq 5
        body_as_json['process_chain']['process_steps'].each do |result|
          expect(result['execution_errors']).to eq ""
        end
      end
    end
  end
  
  def perform_execute_request(auth_headers, data)
    execute_recipe_request(version, auth_headers, data)
  end

  def stub_xsl_download(remote_uri, xsl_file)
    stub_request(:get, remote_uri).
        to_return(:status => 200, :body => xsl_file, :headers => {})
  end
end