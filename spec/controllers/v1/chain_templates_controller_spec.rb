describe Api::V1::ChainTemplatesController, type: :controller do
  include Devise::TestHelpers

  let!(:user)           { FactoryGirl.create(:user, password: "password", password_confirmation: "password") }

  let!(:name)             { "My Splendiferous PNG to JPG transmogrifier" }
  let!(:description)      { "It transmogrifies! It transforms! It even goes across filetypes!" }
  let!(:attributes)           { [:name, :description] }

  let!(:chain_template_params) {
    {
        chain_template: {
            name: name,
            description: description
        }
    }
  }

  describe "POST create" do

    context 'if a valid token is supplied' do

      context 'if the chain template is valid' do
        it "should assign" do
          perform_create_request(user.create_new_auth_token, chain_template_params)

          expect(response.status).to eq 200
          new_chain_template = assigns[:new_chain_template]
          expect(new_chain_template).to be_a ChainTemplate
          attributes.each do |attribute|
            expect(new_chain_template.send(attribute)).to eq self.send(attribute)
          end
        end

        context 'if there are steps supplied' do

          let!(:docx_to_xml)      { FactoryGirl.create(:step_class, name: "DocxToXml") }
          let!(:xml_to_html)      { FactoryGirl.create(:step_class, name: "XmlToHtml") }

          context 'presented as a series of steps with positions included' do
            let!(:step_params)      { [{position: 1, name: "DocxToXml"}, {position: 2, name: "XmlToHtml" }] }

            context 'and they are valid' do
              before do
                chain_template_params[:steps_with_positions] = step_params
              end

              it "should create the template with step templates" do
                perform_create_request(user.create_new_auth_token, chain_template_params)

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
                perform_create_request(user.create_new_auth_token, chain_template_params)

                expect(response.status).to eq 422
              end

              it "should not create the template with duplicate numbers" do
                chain_template_params[:steps_with_positions] = [{position: 1, name: "DocxToXml"}, {position: 1, name: "XmlToHtml" }]
                perform_create_request(user.create_new_auth_token, chain_template_params)

                expect(response.status).to eq 422
              end

              it "should not create the template with incorrect numbers" do
                chain_template_params[:steps_with_positions] = [{position: 0, name: "DocxToXml"}, {position: 1, name: "XmlToHtml" }]
                perform_create_request(user.create_new_auth_token, chain_template_params)

                expect(response.status).to eq 422
              end

              it "should not create the template with skipped steps" do
                chain_template_params[:steps_with_positions] = [{position: 1, name: "DocxToXml"}, {position: 6, name: "XmlToHtml" }]
                perform_create_request(user.create_new_auth_token, chain_template_params)

                expect(response.status).to eq 422
              end

              it "should not create the template with nonsequential numbers" do
                chain_template_params[:steps_with_positions] = [{position: 2, name: "XmlToHtml" }, {position: 1, name: "DocxToXml"}]
                perform_create_request(user.create_new_auth_token, chain_template_params)

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
                perform_create_request(user.create_new_auth_token, chain_template_params)

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
                perform_create_request(user.create_new_auth_token, chain_template_params)

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
          perform_create_request(user.create_new_auth_token, chain_template_params)

          expect(response.status).to eq 422
        end
      end
    end

    context 'if no valid token is supplied' do

      it "should not assign anything" do
        perform_create_request({}, chain_template_params)

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
          self.send("perform_#{method}_request", user.create_new_auth_token, chain_template_params.merge(id: chain_template.id))

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
          self.send("perform_#{method}_request", {}, chain_template_params.merge(id: chain_template.id))

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
          perform_index_request(user.create_new_auth_token)

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
          perform_index_request(user.create_new_auth_token)

          expect(response.status).to eq 200
          expect(assigns[:chain_templates].to_a).to eq [template_1]
        end
      end
    end

    context 'if no valid token is supplied' do

      it "should not assign anything" do
        perform_index_request({})

        expect(response.status).to eq 401
        expect(assigns[:chain_template]).to be_nil
      end
    end
  end

  describe "GET show" do

    context 'if a valid token is supplied' do

      context 'if the template does not exist' do

        it "should return an error" do
          perform_show_request(user.create_new_auth_token, {id: "nonsense"})

          expect(response.status).to eq 404
          expect(assigns[:chain_template]).to be_nil
        end

      end

      context 'the template exists' do

        context 'the template belongs to the user' do
          let!(:template)      { FactoryGirl.create(:chain_template, user: user) }

          it "should find the template" do
            perform_show_request(user.create_new_auth_token, {id: template.id})

            expect(response.status).to eq 200
            expect(assigns[:chain_template]).to eq template
          end
        end

        context 'the template belongs to another user' do
          let!(:other_user)     { FactoryGirl.create(:user) }
          let!(:template)       { FactoryGirl.create(:chain_template, user: other_user) }

          it "should not find the template" do
            perform_show_request(user.create_new_auth_token, {id: template.id})

            expect(response.status).to eq 404
            expect(assigns[:chain_template]).to be_nil
          end
        end


      end
    end

    context 'if no valid token is supplied' do

      it "should not return anything" do
        perform_show_request({}, {id: "rubbish"})

        expect(response.status).to eq 401
        expect(assigns[:chain_template]).to be_nil
      end
    end
  end

  describe "DELETE destroy" do

    context 'if a valid token is supplied' do

      context 'if the template does not exist' do

        it "should return an error" do
          perform_archive_request(user.create_new_auth_token, {id: "nonsense"})

          expect(response.status).to eq 404
          expect(assigns[:chain_template]).to be_nil
        end

      end

      context 'the template exists' do

        context 'the template belongs to the user' do
          let!(:template)      { FactoryGirl.create(:chain_template, user: user) }

          it "should find the template" do
            perform_archive_request(user.create_new_auth_token, {id: template.id})

            expect(response.status).to eq 200
            expect(assigns[:chain_template]).to eq template
          end
        end

        context 'the template belongs to another user' do
          let!(:other_user)     { FactoryGirl.create(:user) }
          let!(:template)       { FactoryGirl.create(:chain_template, user: other_user) }

          it "should not find the template" do
            perform_archive_request(user.create_new_auth_token, {id: template.id})

            expect(response.status).to eq 404
            expect(assigns[:chain_template]).to be_nil
          end
        end
      end
    end

    context 'if no valid token is supplied' do

      it "should not return anything" do
        perform_archive_request({}, {id: "rubbish"})

        expect(response.status).to eq 401
        expect(assigns[:chain_template]).to be_nil
      end
    end
  end

  # request.headers.merge!(auth_headers)
  # this is special for controller tests - you can't just merge them in manually for some reason

  def perform_create_request(auth_headers, data = {})
    request.headers.merge!(auth_headers)
    create_chain_template('v1', data)
  end

  def perform_put_request(auth_headers, data)
    request.headers.merge!(auth_headers)
    update_chain_template('v1', data)
  end

  def perform_patch_request(auth_headers, id_hash, data = {})
    request.headers.merge!(auth_headers)
    patch_chain_template('v1', id_hash, data)
  end

  def perform_index_request(auth_headers, data = {})
    request.headers.merge!(auth_headers)
    index_chain_template('v1', data)
  end

  def perform_show_request(auth_headers, data = {})
    request.headers.merge!(auth_headers)
    show_chain_template('v1', data)
  end

  def perform_archive_request(auth_headers, data = {})
    request.headers.merge!(auth_headers)
    archive_chain_template('v1', data)
  end
end