require_relative 'version'

describe Api::V1::OrganisationsController, type: :controller do
  include Devise::TestHelpers
  let!(:user)			    { FactoryGirl.create(:user) }
  let!(:super_user)   { FactoryGirl.create(:user, super_user: true) }
  let(:name)          {"Mystery Company"}
  let(:description)   {'Such Mystery. Wow.'}

  let!(:org_user)             {FactoryGirl.create(:user, name: "Shirley") }
  let!(:unassociated_user)    {FactoryGirl.create(:user, name: "Drifter") }
  let(:original_organisation) {FactoryGirl.create(:organisation, name: "There is no Company Ltd", description: 'You can find us at 123 nofixed abode')}
  let(:existing_membership)   {FactoryGirl.create(:membership, user: org_user, organisation: original_organisation)}
  let(:existing_membership)   {FactoryGirl.create(:membership, user: user, organisation: original_organisation, admin: true)}
  let(:new_name)          {"Erma Gerd, Company"}
  let(:new_description)   {'We changed stuff'}


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
    let(:organisation_params) {
      {
        organisations:{
          name: new_name,
          description: new_description
        }
      }
    }
    before do
      request_with_auth(user.create_new_auth_token) do
        perform_put_request(organisation_params)
        # self.send("perform_#{method}_request", organisation_params.merge(id: original_organisation.id))
      end
    end

    it "changes org description successfully" do
      expect(response.status).to eq 200
      new_organisation = Organisation.find original_organisation.id
      expect(new_organisation.description).to eq new_description
    end
    it "changes org name successfully" do
      expect(response.status).to eq 200
      new_organisation = Organisation.find original_organisation.id
      expect(new_organisation.name).to eq new_name
    end
  end

  context "with a super user" do
    let(:organisation_params) {
      {
        organisations:{
          name: new_name,
          description: new_description
        }
      }
    }
    before do
      request_with_auth(super_user.create_new_auth_token) do
        perform_put_request(organisation_params)
      end
    end
    it "changes org description successfully" do
      expect(response.status).to eq 200
      new_organisation = Organisation.find original_organisation.id
      expect(new_organisation.description).to eq new_description
    end
    it "changes org name successfully" do
      expect(response.status).to eq 200
      new_organisation = Organisation.find original_organisation.id
      expect(new_organisation.name).to eq new_name
    end
  end

  context "with a user that is not an administrator of the organisation" do
    let(:organisation_params) {
      {
        organisations:{
          name: new_name,
          description: new_description
        }
      }
    }
    before do
      request_with_auth(org_user.create_new_auth_token) do
        perform_put_request(organisation_params)
      end
    end
    it "cannot change the org description" do
      the_organisation = Organisation.find original_organisation.id
      expect(the_organisation.description).to eq original_organisation.description
    end
    it "cannot change the org name" do
      the_organisation = Organisation.find original_organisation.id
      expect(the_organisation.name).to eq original_organisation.name

    end
    it "should fail" do
      expect(response.status).to eq 422
    end
  end
  context "with a user that is not a member of the organisation" do
    let(:organisation_params) {
      {
        organisations:{
          name: new_name,
          description: new_description
        }
      }
    }
    before do
      request_with_auth(unassociated_user.create_new_auth_token) do
        perform_put_request(organisation_params)
      end
    end
    it "cannot change the org description" do
      # expect() the organisation to remain unchanged
    end
    it "cannot change the org name" do

    end
    it "should fail" do
      expect(response.status).to eq 422
    end
  end

  def perform_put_request(data)
    put_update_request(version, data)
  end
end
