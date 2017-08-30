require 'rails_helper'
require_relative '../version'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

describe "Account executes a real recipe" do

  # URL: /api/recipes/:id/execute
  # Method: POST
  # Execute a specific recipe belonging to the current account

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: account@example.com, auth_token: asdf" -X POST --form "input_files=[@my-file.txt], callback_url=mysite.com/callback" http://localhost:3000/api/recipes/:id/execute

  describe "POST execute recipe" do

    let!(:account)             { create(:account, password: "password", password_confirmation: "password") }
    let!(:auth_headers)     { account.new_jwt }
    let!(:html_file)        { fixture_file_upload('files/test.html', 'text/html') }
    let!(:docx_file)        { fixture_file_upload('files/basic_doc.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }

    let!(:recipe)           { create(:recipe, account: account, step_classes: [
        xsweet_step_1_extract_step_class.to_s,
        shoutifier_step_class.to_s,
        modified_files_step_class.to_s]) }

    let!(:execution_params) {
      {
          input_files: docx_file,
          id: recipe.id
      }
    }

    before do
      stub_request(:get, "https://gitlab.coko.foundation/XSweet/XSweet/raw/ink-api-publish/applications/docx-extract/docx-html-extract.xsl").
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: File.read(Rails.root.join('spec/fixtures/files/xsweet_pipeline/docx-html-extract.xsl')), headers: {})

    end

    context 'and execution is successful' do
      it 'returns the objects' do
        perform_execute_request(auth_headers, execution_params)

        expect(response.status).to eq(200)
        expect(body_as_json['process_chain']['successful'])
        expect(body_as_json['process_chain']['process_steps'].count).to eq 3
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
        expect(body_as_json['process_chain']['input_file_manifest']).to match(manifests[:incoming])
        expect(body_as_json['process_chain']['output_file_manifest']).to match(manifests[:'3'])
      end

      it 'also returns the first step info' do
        perform_execute_request(auth_headers, execution_params)

        result = body_as_json['process_chain']['process_steps'][0]
        expect(result['execution_errors']).to eq ""
        expect(result['successful']).to eq true
        expect(result['started_at']).to_not be_nil
        expect(result['finished_at']).to_not be_nil
        ap result['output_file_manifest']
        expect(result['output_file_manifest']).to match_array manifests[:"1"]
      end

      it 'also returns the second step info' do
        perform_execute_request(auth_headers, execution_params)

        result = body_as_json['process_chain']['process_steps'][1]
        expect(result['execution_errors']).to eq ""
        expect(result['successful']).to eq true
        expect(result['started_at']).to_not be_nil
        expect(result['finished_at']).to_not be_nil
        expect(result['output_file_manifest']).to match_array manifests[:"2"]
      end

      it 'also returns the third step info' do
        perform_execute_request(auth_headers, execution_params)

        result = body_as_json['process_chain']['process_steps'][2]
        expect(result['execution_errors']).to eq ""
        expect(result['successful']).to eq true
        expect(result['started_at']).to_not be_nil
        expect(result['finished_at']).to_not be_nil
        ap "Testing #{result['position']}"
        ap result['output_file_manifest']
        expect(result['output_file_manifest']).to match_array manifests[:"3"]
      end

      it 'has the correct number of steps' do
        perform_execute_request(auth_headers, execution_params)

        expect(body_as_json['process_chain']['process_steps'].count).to eq 3
      end
    end
  end
  
  def perform_execute_request(auth_headers, data)
    execute_recipe_request(version, auth_headers, data)
  end
end

def manifests
  {
      incoming: incoming_manifest,
      '1': xsweet_step_manifest,
      '2': shoutifier_step_manifest,
      '3': modified_step_manifest
  }
end

def incoming_manifest
  [{"path"=>"basic_doc.docx",
    "size"=>"4.8 kB",
    "checksum"=>"9e488bc7237c824490bdc707673971f1"}]
end

def xsweet_step_manifest
  [
      {
      'path' => "docx-html-extract.xsl",
      'size' => "8.7 kB",
      'checksum' => "97e34e755a802da78c206ff87eeaac1c",
      'tag' => "new"
      },
      {
          'path' => "basic_doc.html",
          'size' => "380 bytes",
          'checksum' => "d8972a7e18099638c6ea037512717540",
          'tag' => 'new'
      },
      {
      'path' => "basic_doc/[Content_Types].xml",
      'size' => "1.3 kB",
      'checksum' => "ef7c7aab4ed1c89c4d286053052eac61",
      'tag' => 'new'
      },
      {
      'path' => "basic_doc/word/settings.xml",
      'size' => "208 bytes",
      'checksum' => "a4e1cd692809f2f552a8386c2f1d248f",
      'tag' => 'new'
      },
      {
      'path' => "basic_doc/word/styles.xml",
      'size' => "2.3 kB",
      'checksum' => "aee2c9c55cba7b33f39956161c387ddb",
      'tag' => 'new'
      },
      {
      'path' => "basic_doc/word/numbering.xml",
      'size' => "4.8 kB",
      'checksum' => "972926acd198e9688b89ed974ef9947a",
      'tag' => 'new'
      },
      {
      'path' => "basic_doc/word/document.xml",
      'size' => "1.8 kB",
      'checksum' => "a91ac4b6a40d38081f2a7d689c760166",
      'tag' => 'new'
      },
      {
      'path' => "basic_doc/word/fontTable.xml",
      'size' => "853 bytes",
      'checksum' => "8607336877646f51f438674727da21cb",
      'tag' => 'new'
      },
      {
      'path' => "basic_doc/word/_rels/document.xml.rels",
      'size' => "664 bytes",
      'checksum' => "5e0aa4a310402d3df359dc3db5b8eccc",
      'tag' => 'new'
      },
      {
      'path' => "basic_doc/docProps/app.xml",
      'size' => "360 bytes",
      'checksum' => "53781b1580dcf39cb563cbea6469b977",
      'tag' => 'new'
      },
      {
      'path' => "basic_doc/docProps/core.xml",
      'size' => "505 bytes",
      'checksum' => "e0636be1f07e192cde84087d93dd3f06",
      'tag' => 'new'
      },
      {
      'path' => "basic_doc.docx",
      'size' => "4.8 kB",
      'checksum' => "9e488bc7237c824490bdc707673971f1",
      'tag' => 'identical'
      }
  ]
end

def shoutifier_step_manifest
  [
      {
          'path' => "docx-html-extract.xsl",
          'size' => "8.7 kB",
          'checksum' => "97e34e755a802da78c206ff87eeaac1c",
          'tag' => 'identical'
      },
      {
          'path' => "basic_doc/[Content_Types].xml",
          'size' => "1.3 kB",
          'checksum' => "ef7c7aab4ed1c89c4d286053052eac61",
          'tag' => 'identical'
      },
      {
          'path' => "basic_doc/word/settings.xml",
          'size' => "208 bytes",
          'checksum' => "a4e1cd692809f2f552a8386c2f1d248f",
          'tag' => 'identical'
      },
      {
          'path' => "basic_doc/word/styles.xml",
          'size' => "2.3 kB",
          'checksum' => "aee2c9c55cba7b33f39956161c387ddb",
          'tag' => 'identical'
      },
      {
          'path' => "basic_doc/word/numbering.xml",
          'size' => "4.8 kB",
          'checksum' => "972926acd198e9688b89ed974ef9947a",
          'tag' => 'identical'
      },
      {
          'path' => "basic_doc/word/document.xml",
          'size' => "1.8 kB",
          'checksum' => "a91ac4b6a40d38081f2a7d689c760166",
          'tag' => 'identical'
      },
      {
          'path' => "basic_doc/word/fontTable.xml",
          'size' => "853 bytes",
          'checksum' => "8607336877646f51f438674727da21cb",
          'tag' => 'identical'
      },
      {
          'path' => "basic_doc/word/_rels/document.xml.rels",
          'size' => "664 bytes",
          'checksum' => "5e0aa4a310402d3df359dc3db5b8eccc",
          'tag' => 'identical'
      },
      {
          'path' => "basic_doc/docProps/app.xml",
          'size' => "360 bytes",
          'checksum' => "53781b1580dcf39cb563cbea6469b977",
          'tag' => 'identical'
      },
      {
          'path' => "basic_doc/docProps/core.xml",
          'size' => "505 bytes",
          'checksum' => "e0636be1f07e192cde84087d93dd3f06",
          'tag' => 'identical'
      },
      {
          'path' => "basic_doc.html",
          'size' => "390 bytes",
          'checksum' => "c8cab16435721d4ea65b87e8462ab59b",
          'tag' => 'modified'
      },
      {
          'path' => "basic_doc.docx",
          'size' => "4.8 kB",
          'checksum' => "9e488bc7237c824490bdc707673971f1",
          'tag' => 'identical'
      }
  ]
end

def modified_step_manifest
  [
      {
          'path' => "basic_doc.html",
          'size' => "390 bytes",
          'checksum' => "c8cab16435721d4ea65b87e8462ab59b",
          'tag' => 'identical'
      }
  ]
end