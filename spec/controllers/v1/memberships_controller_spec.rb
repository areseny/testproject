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
  
  let!(:org_user)     				{FactoryGirl.create(:user, name: "Shirley") }
  let!(:org_user_2)   				{FactoryGirl.create(:user, name: "Roger") }
  let!(:instance_user)   			{FactoryGirl.create(:user, name: "Victor") }
  let!(:admin_user)   				{FactoryGirl.create(:user, name: "Captain Clarence Oveur") }
  let(:original_organisation) 		{FactoryGirl.create(:organisation, name: "There is no Company Ltd", description: 'You can find us at 123 nofixed abode')}
  let(:existing_user_membership)   	{FactoryGirl.create(:membership, user: org_user, organisation: original_organisation)}
  let(:existing_user_membership_2)  {FactoryGirl.create(:membership, user: org_user_2, organisation: original_organisation)}
  let(:existing_admin_membership)   {FactoryGirl.create(:membership, user: user, organisation: original_organisation, admin: true)}
  let(:existing_admin_membership_2) {FactoryGirl.create(:membership, user: admin_user, organisation: original_organisation, admin: true)}


  let(:valid_membership_params) {{
    	memberships:{
      		user_id: user.id,
      		organisation_id: organisation.id
    	}
  	}}
	let(:instance_user_membership_params) {{
    	memberships:{
      		user_id: instance_user.id,
      		organisation_id: original_organisation.id
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

#TODO: before and let calls
 describe "Update" do
 	context 'for an organisation' do
	  context 'with an admin of the organisation' do
	    context 'grants rights' do
	    	it 'grants admin rights to an organisation user' do
			    expect(response.status).to eq 200
			    changed_user = Membership.find existing_user_membership.id
			    expect(changed_user.admin).to eq true
			end
			it "cannot grant rights to an instance user that is not a member of the organisation" do
			    expect{
		    			request_with_auth(user.create_new_auth_token) do
        					perform_create_request(instance_user_membership_params)
	            		end
	            	}.to_not change{Membership.count}
	          		expect(response.status).to eq 422
			end 
	    end
	    context 'revokes rights' do
	    	it "can revoke admin priveledges of an org user" do
		    	expect(response.status).to eq 200
			    changed_user = Membership.find existing_admin_membership_2.id
			    expect(changed_user.admin).to eq false
		    end
		    it "can revoke user priveldges of an org user" do
		    	expect(response.status).to eq 200
			    changed_user = Membership.find existing_user_membership.id
			    expect(changed_user.admin).to eq false
		    end
		    it "can revoke own access if another org admin exists" do
		    	expect(response.status).to eq 200
			    changed_user = Membership.find existing_user_membership.id
			    expect(changed_user.admin).to eq false
		    end
	    end
	  context 'with a super user' do
	    it "grants org admin rights to an org user" do
	    end
	    it "revokes admin priveledges of an org user" do
	    end
	    it "revokes user priveldges of an org user" do
	    end
	    it "grants rights to an instance user" do	
		end 
		it "grants rights to a non-existent user" do	
		end 
	  end
	  context 'with a user that is not an administrator of the organisation' do
	    it "cannot grant org admin rights for themselves" do
	    	expect(response.status).to eq 422
	      # expect() the organisation to remain unchanged
	    end
	    it "cannot grant org admin rights to an org user" do
	    end
	    it "cannot revoke admin priveledges of an org user" do
	    end
	    it "cannot revoke user priveldges of an org user" do
	    end
	  end
	end
	context 'for a user' do
		context 'is a standard user' do
			it "can revoke own admin access if another org admin exists for that org" do
	    	end
	    	it "can revoke own user access of any organisation" do
	    	end
	    	it "cannot grant admin access for themselves" do
	    	end
		end
		context 'is a super user' do
			it "can grant admin access for themselves" do
	    	end
		end
	end
end