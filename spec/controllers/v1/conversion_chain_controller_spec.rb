describe Api::V1::ConversionChainsController, type: :controller do
  include Devise::TestHelpers

  let!(:user)           { FactoryGirl.create(:user, password: "password", password_confirmation: "password") }

  let!(:docx_to_xml)      { FactoryGirl.create(:step_class, name: "DocxToXml") }
  let!(:xml_to_html)      { FactoryGirl.create(:step_class, name: "XmlToHtml") }

  describe "POST execute" do

    let!(:demo_step)        { FactoryGirl.create(:step_class, name: "Step") }
    let!(:xml_file)         { fixture_file_upload('files/test_file.xml', 'text/xml') }
    let!(:photo_file)       { fixture_file_upload('files/kitty.jpeg', 'image/jpeg') }
    let!(:recipe_step)    { FactoryGirl.create(:recipe_step, step_class: demo_step) }
    let!(:conversion_chain) { FactoryGirl.create(:conversion_chain, user: user) }

    let!(:execution_params) {
        {
            id: conversion_chain.id,
            input_file: photo_file
        }
    }

    context 'if a valid token is supplied' do

      context 'if a file is supplied' do
        it 'should try to execute the conversion chain' do
          request_with_auth(user.create_new_auth_token) do
            perform_execute_request(execution_params)
          end

          expect(response.status).to eq 200
          expect(assigns(:conversion_chain)).to eq conversion_chain
          expect(assigns(:conversion_chain).executed_at).to_not be_nil
        end
      end

      context 'if no file is supplied' do
        before do
          execution_params.delete(:input_file)
        end

        it 'should fail' do
          request_with_auth(user.create_new_auth_token) do
            perform_execute_request(execution_params)
          end

          expect(response.status).to eq 422
        end
      end
    end

    context 'if no valid token is supplied' do

      it "should not assign anything" do
        request_with_auth do
          perform_execute_request(execution_params)
        end

        expect(response.status).to eq 401
      end
    end

  end

  def perform_execute_request(data = {})
    execute_recipe(version, data)
  end

  def perform_create_request(data = {})
    post_create_request(version, data)
  end

  def perform_put_request(data)
    put_update_request(version, data)
  end

  def perform_patch_request(data = {})
    patch_update_request(version, data)
  end

  def perform_index_request(data = {})
    get_index_request(version, data)
  end

  def perform_show_request(data = {})
    get_show_request(version, data)
  end

  def perform_destroy_request(data = {})
    delete_destroy_request(version, data)
  end

  def version
    'v1'
  end
end