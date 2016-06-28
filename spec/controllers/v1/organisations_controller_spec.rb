require_relative 'version'

describe Api::V1::OrganisationsController, type: :controller do
  include Devise::TestHelpers
  let!(:user)			    { FactoryGirl.create(:user) }
  let!(:super_user)   { FactoryGirl.create(:user, super_user: true) }
  let(:name)          {"Mystery Company"}
  let(:description)   {'Such Mystery. Wow.'}

  let!(:org_user)     { FactoryGirl.create(:user, name: "Shirley") }
  let!(:org_user_2)   { FactoryGirl.create(:user, name: "Roger") }
  let!(:org_user_3)   { FactoryGirl.create(:user, name: "Victor") }
  let(:original_organisation) {FactoryGirl.create(:organisation, name: "There is no Company Ltd", description: 'You can find us at 123 nofixed abode')}
  let(:existing_membership)   {FactoryGirl.create(:membership, user: org_user, organisation: original_organisation)}
  let(:existing_membership)   {FactoryGirl.create(:membership, user: org_user_2, organisation: original_organisation)}
  let(:existing_membership)   {FactoryGirl.create(:membership, user: user, organisation: original_organisation, admin: true)}


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

describe "Update" do
  context "with an admin of the organisation" do
    it "changes org description successfully" do
    end
    it "changes org name successfully" do
    end
  context "with a super user" do
    it "changes org description successfully" do
    end
    it "changes org name successfully" do
    end
  end
  context "with a user that is not an administrator of the organisation" do
    it "cannot change the org description" do
      expect(response.status).to eq 422
      # expect() the organisation to remain unchanged
    end
    it "cannot change the org name" do
    end

    # it "should fail" do
    #   expect(response.status).to eq 422
    #   # expect() the organisation to remain unchanged
    # end
  end
end
