require_relative 'version'

describe Api::V1::OrganisationsController, type: :controller do
  include Devise::TestHelpers
  let!(:user)			{ FactoryGirl.create(:user, password: "password", password_confirmation: "password") }
  let(:name){"Mystery Company"}
  let(:description){'Such Mystery. Wow.'}
  
  describe "POST create" do

    context 'if a valid token is supplied' do
      context 'with valid parameters' do
        let(:organisation_params) {
          {
            organisations:{
              name: name,
              description: description
            }
          }
        }
        before do
          request_with_auth(user.create_new_auth_token) do
            perform_create_request(organisation_params)
          end
        end
        it "successfully assembles an organisation" do
          new_organisation = assigns[:new_organisation]
          expect(new_organisation).to be_a Organisation
          expect(new_organisation.name).to eq name
          expect(new_organisation.description).to eq description
          

        end
        it "creates a new persisted organisation" do
          new_organisation = Organisation.last
          expect(new_organisation.name).to eq name
          expect(new_organisation.description).to eq description
        end
        it "assigns the creator to be an administrator of the organisation" do
          membership = Membership.last
          new_organisation = Organisation.last
          expect(membership.organisation).to eq new_organisation
          expect(membership.user).to eq user
          expect(membership.admin).to eq true
        end
      end
      context 'with an invalid name parameters' do
        let(:organisation_params) {
          {
            organisations:{
              name: '',
              description: description
            }
          }
        }
        before do
          request_with_auth(user.create_new_auth_token) do
            perform_create_request(organisation_params)
          end
        end
        it "does not create an organisation" do
            expect(response.status).to eq 422
        end
      end
    end
  end

  context 'if no token is supplied' do
    let(:organisation_params) {
      {
        organisations:{
          name: name,
          description: description
        }
      }
    }
    before do
      request_with_auth do
        perform_create_request(organisation_params)
      end
    end
    it "does not create an organisation" do
      expect(assigns[:new_organisation]).to be_nil
    end

    it "returns an error" do
      expect(response.status).to eq 401
    end
  end


  def perform_create_request(data = {})
    post_create_request(version, data)
  end

end
