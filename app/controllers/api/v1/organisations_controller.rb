module Api
  module V1
    class OrganisationsController < ApplicationController
    	before_action :authenticate_api_user!, only: [:create, :index]
      before_action :admin_or_super_user_only!, only: [:update]

      # before_action :super_user_only!, only: [:index]
    	respond_to :json


    	def create
    		create_new_organisation
	    	render json: @new_organisation, root: false
	    rescue => e
	    	render_error(e)
	    end

      def index
        @organisations = current_api_user.administered_organisations
        @organisations = Organisation.all if current_api_user.super_user?
      end  

      def update
        #can update the name, description, and memberships of an organisation
      end

	    private
        def create_new_organisation
	    		 @new_organisation = Organisation.create(organisation_params)
           @new_organisation.memberships.create(user: current_api_user, admin: true)
        end

    	def organisation_params
   			params.require(:organisations).permit(:name, :description)
		  end

    end
  end
end
