module Api
  module V1
    class MembershipsController < ApplicationController
    	before_action :authenticate_api_user!, only: [:create]
    	before_action :admin_or_super_user_only!, only: [:create]
    	respond_to :json

    	def create
    		# if current_api_user is an admin of the organisation (or SU), can create membership

    		new_membership
    		new_membership.save!

    		#What should show?
	    	#render json: new_membership, root: false
	    rescue => e
	    	render_error(e)
	    end

	    private
        
        def new_membership
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