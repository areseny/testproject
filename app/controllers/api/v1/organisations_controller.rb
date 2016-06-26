module Api
  module V1
    class OrganisationsController < ApplicationController
    	before_action :authenticate_api_user!, only: [:create]
      # before_action :super_user_only!, only: [:create, :index]
    	respond_to :json


    	def create
    		create_new_organisation
	    	render json: @new_organisation, root: false
	    rescue => e
	    	render_error(e)
	    end

      def index
        @organisations = Organisation.all
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
