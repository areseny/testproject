module Api
  module V1
    class OrganisationsController < ApplicationController
    	before_action :authenticate_api_user!, only: [:create, :list]
    	respond_to :json

    	def create
    		new_organisation
    		new_organisation.save!

	    	render json: new_organisation, root: false
	    rescue => e
	    	# error handling goes here
	    end

	    private

	    def new_organisation
	    	unless @new_organisation
	    		@new_organisation = Organisation.new(organisation_params)
	    		Membership.new(organisation: new_organisation, user: current_api_user, admin: true)
	    	end
    	end

    	def admin
		end

    	def organisation_params
   			params.require(:organisations).permit(:name, :description)
		end

    end
  end
end