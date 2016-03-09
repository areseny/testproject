describe Api::V1::ChainTemplatesController, type: :controller do
  include Devise::TestHelpers

  let!(:user)           { FactoryGirl.create(:user, password: "password", password_confirmation: "password") }

  describe "POST create" do

    let!(:name)             { "My Splendiferous PNG to JPG transmogrifier" }
    let!(:description)      { "It transmogrifies! It transforms! It even goes across filetypes!" }

    let!(:chain_template_params) {
      {
          chain_template: {
              name: name,
              description: description,
              uid: user.email
          }
      }
    }

    context 'if a valid token is supplied' do

      it "should assign" do
        perform_create_request(user.create_new_auth_token, chain_template_params.to_json)

        expect(response.status).to eq 200
        expect(assigns[:chain_template]).to be_a ChainTemplate
      end
    end

    context 'if no valid token is supplied' do

      it "should not assign anything" do
        perform_create_request({}, chain_template_params.to_json)

        expect(response.status).to eq 401
        expect(assigns[:chain_template]).to be_nil
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

  # request.headers.merge!(auth_headers)
  # this is special for controller tests - you can't just merge them in manually for some reason

  def perform_create_request(auth_headers, data = {})
    request.headers.merge!(auth_headers)
    create_chain_template('v1', {}, data)
  end

  def perform_index_request(auth_headers, data = {})
    request.headers.merge!(auth_headers)
    index_chain_template('v1', {}, data)
  end

  def perform_show_request(auth_headers, data = {})
    request.headers.merge!(auth_headers)
    show_chain_template('v1', {}, data)
  end
end