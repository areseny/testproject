module Api
  module V1
    class MembershipsController < ApplicationController
    	before_action :authenticate_api_user!, only: [:create]
    	before_action :admin_or_super_user_only!, only: [:create]
    	respond_to :json

    	def create
    		create_new_membership
    		new_membership.save!

	    	render json: @new_membership.organisation, root: false
	    rescue => e
	    	render_error(e)
	    end

	    private
        
        def create_new_membership
       		unless @new_membership
	   		 	@new_membership = Membership.new(membership_params)
    		end
   		end

    	def membership_params
   			params.require(:memberships).permit(:organisation, :user, :admin)
		end
    end
  end
end