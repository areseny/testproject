require_relative 'version'

describe Api::V1::ConversionChainsController, type: :controller do
  include Devise::TestHelpers

  let!(:user)             { FactoryGirl.create(:user, password: "password", password_confirmation: "password") }

  let!(:docx_to_xml)      { FactoryGirl.create(:step_class, name: "DocxToXml") }
  let!(:xml_to_html)      { FactoryGirl.create(:step_class, name: "XmlToHtml") }

  describe "GET retry" do

    let!(:demo_step)        { FactoryGirl.create(:step_class, name: "Step") }
    let!(:xml_file)         { fixture_file_upload('files/test_file.xml', 'text/xml') }
    let!(:photo_file)       { fixture_file_upload('files/kitty.jpeg', 'image/jpeg') }
    let!(:recipe_step)      { FactoryGirl.create(:recipe_step, step_class: demo_step) }
    let!(:conversion_step)  { FactoryGirl.create(:conversion_step) }
    let!(:conversion_chain) { conversion_step.conversion_chain }

    let!(:retry_params) {
        {
            id: conversion_chain.id
        }
    }

    before do
      recipe_step.update_attribute(:recipe_id, conversion_chain.recipe.id)
      conversion_chain.update_attribute(:user_id, user.id)
      conversion_chain.recipe.update_attribute(:user_id, user.id)
    end

    context 'if a valid token is supplied' do

      context 'if the chain belongs to that user' do

        context 'if a file is supplied' do
          before do
            FileUploader.enable_processing = true
            @uploader = FileUploader.new(conversion_chain, :input_file)

            File.open('spec/fixtures/files/test_file.xml') do |f|
              @uploader.store!(f)
            end
          end

          context 'if the recipe has no steps' do
            before do
              recipe_step.destroy
            end

            it 'should try to execute the conversion chain' do
              request_with_auth(user.create_new_auth_token) do
                perform_retry_request(retry_params)
              end

              expect(response.status).to eq 422
            end
          end

          context 'if the recipe has steps' do
            it 'should try to execute the conversion chain' do
              request_with_auth(user.create_new_auth_token) do
                perform_retry_request(retry_params)
              end

              expect(response.status).to eq 200
              expect(assigns(:new_chain)).to_not eq conversion_chain
              expect(assigns(:new_chain).executed_at).to_not be_nil
            end
          end
        end
      end
    end

    context 'if no valid token is supplied' do

      it "should not assign anything" do
        request_with_auth do
          perform_retry_request(retry_params)
        end

        expect(response.status).to eq 401
      end
    end

  end

  def perform_retry_request(data = {})
    retry_conversion(version, data)
  end
end