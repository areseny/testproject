describe Api::V1::ChainTemplatesController, type: :controller do
  include Devise::TestHelpers

  let!(:user)           { FactoryGirl.create(:user, password: "password", password_confirmation: "password") }
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

  describe "GET index" do
    context 'if a valid token is supplied' do

      it "should assign" do
        perform_request(user.create_new_auth_token, chain_template_params.to_json)

        puts assigns[:chain_template].inspect
        expect(assigns[:chain_template]).to be_a ChainTemplate
      end
    end

    context 'if no valid token is supplied' do

      it "should not assign anything" do
        perform_request({}, chain_template_params.to_json)

        expect(assigns[:chain_template]).to be_nil
      end
    end

  end

  def perform_request(auth_headers, data)
    create_chain_template('v1', auth_headers, data)
  end
end