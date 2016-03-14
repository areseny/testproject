describe Api::V1::ChainTemplatesController, type: :controller do
  include Devise::TestHelpers

  let!(:user)           { FactoryGirl.create(:user, password: "password", password_confirmation: "password") }

  let!(:name)             { "My Splendiferous PNG to JPG transmogrifier" }
  let!(:description)      { "It transmogrifies! It transforms! It even goes across filetypes!" }

  let!(:docx_to_xml)      { FactoryGirl.create(:step_class, name: "DocxToXml") }
  let!(:xml_to_html)      { FactoryGirl.create(:step_class, name: "XmlToHtml") }

  let!(:attributes)           { [:name, :description] }

  let!(:chain_template_params) {
    {
        chain_template: {
            name: name,
            description: description
        }
    }
  }

  describe "POST execute" do

    let!(:demo_step)        { FactoryGirl.create(:step_class, name: "demo") }
    let!(:file)             { fixture_file_upload('files/test_file.xml', 'text/xml') }
    let!(:step_template)    { FactoryGirl.create(:step_template, step_class: demo_step) }
    let!(:chain_template)   { FactoryGirl.create(:chain_template, user: user, step_templates: [step_template]) }

    let!(:execution_params) {
        {
            id: chain_template.id,
            input_file: file
        }
    }

    context 'if a valid token is supplied' do

      context 'if a file is supplied' do
        it 'should try to execute the conversion chain' do
          request_with_auth(user.create_new_auth_token) do
            perform_execute_request(execution_params)
          end

          expect(response.status).to eq 302
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

  describe "POST create" do

    context 'if a valid token is supplied' do

      context 'if the chain template is valid' do
        it "should assign" do
          request_with_auth(user.create_new_auth_token) do
            perform_create_request(chain_template_params)
          end

          expect(response.status).to eq 200
          new_chain_template = assigns[:new_chain_template]
          expect(new_chain_template).to be_a ChainTemplate
          attributes.each do |attribute|
            expect(new_chain_template.send(attribute)).to eq self.send(attribute)
          end
        end

        context 'if there are steps supplied' do

          context 'presented as a series of steps with positions included' do
            let!(:step_params)      { [{position: 1, name: docx_to_xml.name}, {position: 2, name: xml_to_html.name }] }

            context 'and they are valid' do
              before do
                chain_template_params[:steps_with_positions] = step_params
              end

              it "should create the template with step templates" do
                request_with_auth(user.create_new_auth_token) do
                  perform_create_request(chain_template_params)
                end

                expect(response.status).to eq 200
                new_chain_template = assigns[:new_chain_template]
                expect(new_chain_template).to be_a ChainTemplate
                attributes.each do |attribute|
                  expect(new_chain_template.send(attribute)).to eq self.send(attribute)
                end
                expect(new_chain_template.step_templates.count).to eq 2
                expect(new_chain_template.step_templates.sort_by(&:position).map(&:step_class_id)).to eq [docx_to_xml.id, xml_to_html.id]
              end
            end

            context 'and they are incorrect' do

              it "should not create the template for nonexistent step classes" do
                docx_to_xml.destroy
                chain_template_params[:steps_with_positions] = [{position: 1, name: "DocxToXml"}, {position: 1, name: "XmlToHtml" }]

                request_with_auth(user.create_new_auth_token) do
                  perform_create_request(chain_template_params)
                end

                expect(response.status).to eq 422
              end

              it "should not create the template with duplicate numbers" do
                chain_template_params[:steps_with_positions] = [{position: 1, name: "DocxToXml"}, {position: 1, name: "XmlToHtml" }]

                request_with_auth(user.create_new_auth_token) do
                  perform_create_request(chain_template_params)
                end

                expect(response.status).to eq 422
              end

              it "should not create the template with incorrect numbers" do
                chain_template_params[:steps_with_positions] = [{position: 0, name: "DocxToXml"}, {position: 1, name: "XmlToHtml" }]

                request_with_auth(user.create_new_auth_token) do
                  perform_create_request(chain_template_params)
                end

                expect(response.status).to eq 422
              end

              it "should not create the template with skipped steps" do
                chain_template_params[:steps_with_positions] = [{position: 1, name: "DocxToXml"}, {position: 6, name: "XmlToHtml" }]

                request_with_auth(user.create_new_auth_token) do
                  perform_create_request(chain_template_params)
                end

                expect(response.status).to eq 422
              end

              it "should create the template with nonsequential numbers" do
                chain_template_params[:steps_with_positions] = [{position: 2, name: "XmlToHtml" }, {position: 1, name: "DocxToXml"}]

                request_with_auth(user.create_new_auth_token) do
                  perform_create_request(chain_template_params)
                end

                expect(response.status).to eq 200
                new_chain_template = assigns[:new_chain_template]
                expect(new_chain_template).to be_a ChainTemplate
                attributes.each do |attribute|
                  expect(new_chain_template.send(attribute)).to eq self.send(attribute)
                end
                expect(new_chain_template.step_templates.count).to eq 2
              end
            end
          end

          context 'presented as a series of steps with order implicit' do
            context 'and they are valid' do
              before do
                chain_template_params[:steps] = ["DocxToXml", "XmlToHtml"]
              end

              it "should create the template with step templates" do
                request_with_auth(user.create_new_auth_token) do
                  perform_create_request(chain_template_params)
                end

                expect(response.status).to eq 200
                new_chain_template = assigns[:new_chain_template]
                expect(new_chain_template).to be_a ChainTemplate
                attributes.each do |attribute|
                  expect(new_chain_template.send(attribute)).to eq self.send(attribute)
                end
                expect(new_chain_template.step_templates.count).to eq 2
                expect(new_chain_template.step_templates.sort_by(&:position).map(&:step_class_id)).to eq [docx_to_xml.id, xml_to_html.id]
              end
            end

            context 'and they are incorrect' do

              it "should not create the template for nonexistent step classes" do
                docx_to_xml.destroy
                chain_template_params[:steps] = ["DocxToXml", "XmlToHtml"]

                request_with_auth(user.create_new_auth_token) do
                  perform_create_request(chain_template_params)
                end

                expect(response.status).to eq 422
              end
            end
          end
        end

      end

      context 'if the chain template is invalid' do
        before do
          chain_template_params[:chain_template].delete(:name)
        end

        it "should not be successful" do
          request_with_auth(user.create_new_auth_token) do
            perform_create_request(chain_template_params)
          end

          expect(response.status).to eq 422
        end
      end
    end

    context 'if no valid token is supplied' do

      it "should not assign anything" do
        request_with_auth do
          perform_create_request(chain_template_params)
        end

        expect(response.status).to eq 401
        expect(assigns[:new_chain_template]).to be_nil
      end
    end
  end

  [:patch, :put].each do |method|
    describe "#{method.upcase} update" do

      let!(:chain_template)   { FactoryGirl.create(:chain_template, user: user) }

      context 'if a valid token is supplied' do

        it "should assign" do
          request_with_auth(user.create_new_auth_token) do
            self.send("perform_#{method}_request", chain_template_params.merge(id: chain_template.id))
          end

          expect(response.status).to eq 200
          chain_template = assigns[:chain_template]
          expect(chain_template).to be_a ChainTemplate
          attributes.each do |facet|
            expect(chain_template.send(facet)).to eq self.send(facet)
          end
        end
      end

      context 'if no valid token is supplied' do

        it "should not assign anything" do
          request_with_auth do
            self.send("perform_#{method}_request", chain_template_params.merge(id: chain_template.id))
          end

          expect(response.status).to eq 401
          expect(assigns[:new_chain_template]).to be_nil
        end
      end
    end
  end

  describe "GET index" do

    context 'if a valid token is supplied' do

      context 'there are no templates' do

        it "should find no templates" do
          request_with_auth(user.create_new_auth_token) do
            perform_index_request
          end

          expect(response.status).to eq 200
          expect(assigns[:chain_templates]).to eq []
        end

      end

      context 'there are templates' do
        let!(:other_user)      { FactoryGirl.create(:user) }
        let!(:template_1)      { FactoryGirl.create(:chain_template, user: user) }
        let!(:template_2)      { FactoryGirl.create(:chain_template, user: user, active: false) }
        let!(:template_3)      { FactoryGirl.create(:chain_template, user: other_user) }

        it "should find the user's templates" do
          request_with_auth(user.create_new_auth_token) do
            perform_index_request
          end

          expect(response.status).to eq 200
          expect(assigns[:chain_templates].to_a).to eq [template_1]
        end
      end
    end

    context 'if no valid token is supplied' do

      it "should not assign anything" do
        request_with_auth do
          perform_index_request({})
        end

        expect(response.status).to eq 401
        expect(assigns[:chain_template]).to be_nil
      end
    end
  end

  describe "GET show" do

    context 'if a valid token is supplied' do

      context 'if the template does not exist' do

        it "should return an error" do
          request_with_auth(user.create_new_auth_token) do
            perform_show_request({id: "nonsense"})
          end

          expect(response.status).to eq 404
          expect(assigns[:chain_template]).to be_nil
        end

      end

      context 'the template exists' do

        context 'the template belongs to the user' do
          let!(:template)      { FactoryGirl.create(:chain_template, user: user) }

          it "should find the template" do
            request_with_auth(user.create_new_auth_token) do
              perform_show_request({id: template.id})
            end

            expect(response.status).to eq 200
            expect(assigns[:chain_template]).to eq template
          end
        end

        context 'the template belongs to another user' do
          let!(:other_user)     { FactoryGirl.create(:user) }
          let!(:template)       { FactoryGirl.create(:chain_template, user: other_user) }

          it "should not find the template" do
            request_with_auth(user.create_new_auth_token) do
              perform_show_request({id: template.id})
            end

            expect(response.status).to eq 404
            expect(assigns[:chain_template]).to be_nil
          end
        end


      end
    end

    context 'if no valid token is supplied' do

      it "should not return anything" do
        request_with_auth do
          perform_show_request({id: "rubbish"})
        end

        expect(response.status).to eq 401
        expect(assigns[:chain_template]).to be_nil
      end
    end
  end

  describe "DELETE destroy" do

    context 'if a valid token is supplied' do

      context 'if the template does not exist' do

        it "should return an error" do
          request_with_auth(user.create_new_auth_token) do
            perform_archive_request({id: "nonsense"})
          end

          expect(response.status).to eq 404
          expect(assigns[:chain_template]).to be_nil
        end

      end

      context 'the template exists' do

        context 'the template belongs to the user' do
          let!(:template)      { FactoryGirl.create(:chain_template, user: user) }

          it "should find the template" do
            request_with_auth(user.create_new_auth_token) do
              perform_archive_request({id: template.id})
            end

            expect(response.status).to eq 200
            expect(assigns[:chain_template]).to eq template
          end
        end

        context 'the template belongs to another user' do
          let!(:other_user)     { FactoryGirl.create(:user) }
          let!(:template)       { FactoryGirl.create(:chain_template, user: other_user) }

          it "should not find the template" do
            request_with_auth(user.create_new_auth_token) do
              perform_archive_request({id: template.id})
            end

            expect(response.status).to eq 404
            expect(assigns[:chain_template]).to be_nil
          end
        end
      end
    end

    context 'if no valid token is supplied' do

      it "should not return anything" do
        request_with_auth do
          perform_archive_request({id: "rubbish"})
        end

        expect(response.status).to eq 401
        expect(assigns[:chain_template]).to be_nil
      end
    end
  end

  # request.headers.merge!(auth_headers)
  # this is special for controller tests - you can't just merge them in manually for some reason

  def perform_execute_request(data = {})
    execute_chain_template('v1', data)
  end

  def perform_create_request(data = {})
    post_create_request('v1', data)
  end

  def perform_put_request(data)
    put_update_request('v1', data)
  end

  def perform_patch_request(data = {})
    patch_update_request('v1', data)
  end

  def perform_index_request(data = {})
    get_index_request('v1', data)
  end

  def perform_show_request(data = {})
    get_show_request('v1', data)
  end

  def perform_archive_request(data = {})
    delete_destroy_request('v1', data)
  end
end