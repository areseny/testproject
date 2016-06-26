require_relative 'version'

describe Api::V1::MembershipsController, type: :controller do
  include Devise::TestHelpers
  let!(:creator)				{FactoryGirl.create(:user, name: "Jon Arbuckle", password: "password", password_confirmation: "password") }
  let!(:user)					{FactoryGirl.create(:user, name: "Linda the Vet", password: "password", password_confirmation: "password") }
  let!(:other_user)				{FactoryGirl.create(:user, name: "Garfeild the Cat") }
  let!(:another_user)			{FactoryGirl.create(:user, name: "Odie the Dog") }
  let!(:some_user)				{FactoryGirl.create(:user, name: "Nermal the Kitten") }
  let!(:organisation)			{FactoryGirl.create(:organisation)}
  let!(:other_organisation)		{FactoryGirl.create(:organisation, name: "Cats Incorporated")}
  let!(:admin_membership)		{FactoryGirl.create(:membership, organisation: organisation, user: creator, admin: true)}
  let!(:other_admin_membership)	{FactoryGirl.create(:membership, organisation: other_organisation, user: some_user, admin: true)}
  let!(:membership)				{FactoryGirl.create(:membership, organisation: organisation, user: another_user)}
  let(:valid_membership_params) {{
    	memberships:{
      		user_id: user.id,
      		organisation_id: organisation.id
    	}
  	}}

  describe "POST create" do

    context 'if a valid token is supplied' do
    	context 'user is an admin' do
    		context 'with valid parameters' do
	        	it "creates a membership for an instance user" do
	        		request_with_auth(creator.create_new_auth_token) do
	            		perform_create_request(valid_membership_params)
	          		end
	        		
	        		expect(response.status).to eq 200
          			new_membership = assigns[:new_membership]
          			expect(new_membership).to be_a Membership
          			expect(new_membership.user_id).to eq user.id
          			expect(new_membership.organisation_id).to eq organisation.id
	        	end

	        	it "should save the membership" do
		    		expect{
		    			request_with_auth(creator.create_new_auth_token) do
	            			perform_create_request(valid_membership_params)
	            		end
	            	}.to change{Membership.count}.by (1)
		    	end
	    	end
	    	context 'with invalid membership parameters' do
	    		let(:invalid_membership_params) {{
	            	memberships:{
	              		user_id: user.id,
	              		organisation: ""
	            	}
	          	}}
	          	it "should not create a membership" do
	          		expect{
		    			request_with_auth(creator.create_new_auth_token) do
	            			perform_create_request(invalid_membership_params)
	            		end
	            	}.to_not change{Membership.count}
	          		expect(response.status).to eq 422
	          	end
	    	end
	    end
	    xcontext 'user is a super user' do
	    	before do
          		request_with_auth(creator.create_new_auth_token) do
            		perform_create_request(valid_membership_params)
          		end
        	end
	    	it "should create a membership for the given user" do
	    		expect(response.status).to eq 200
      			new_membership = assigns[:new_membership]
      			expect(new_membership).to be_a Membership
      			expect(new_membership.user_id).to eq user.id
      			expect(new_membership.organisation_id).to eq organisation.id
	    	end
	    	it "should save the membership" do
	    		expect{
	    			request_with_auth(creator.create_new_auth_token) do
            			perform_create_request(valid_membership_params)
            		end
            	}.to change(Membership.count).by (1)
	    	end
	    end
	    context 'user is not a super user' do
		    context 'when a organisation user is not an organisation admin' do
		    	before do
	          		request_with_auth(another_user.create_new_auth_token) do
	            		perform_create_request(valid_membership_params)
	          		end
	        	end
	        	it "should not create a membership" do
					expect(response.status).to eq 422
	        	end
		    end
		    context 'the user is an admin of another organisation and not this one' do
		    	before do
	          		request_with_auth(some_user.create_new_auth_token) do
	            		perform_create_request(valid_membership_params)
	          		end
	        	end
	        	it "should not create a membership" do
	        		expect(response.status).to eq 422
	        	end

		    end
		    
		    context 'the user is not a member of any organisation' do
		    	before do
	          		request_with_auth(other_user.create_new_auth_token) do
	            		perform_create_request(valid_membership_params)
	          		end
	        	end
	        	it "should not create a membership" do
	        		expect(response.status).to eq 422
	        	end
	        end
	    end  
	end
    
    def perform_create_request(data = {})
    	post_create_request(version, data)
  	end
  end

 end