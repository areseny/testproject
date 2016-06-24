module Api
  module V1
    class OrganisationsController < ApplicationController
    	before_action :authenticate_api_user!, only: [:create, :list]
    	respond_to :json

    	def create
    		new_organisation
        #new_organisation.save!
        puts "Hai"
	    	render json: new_organisation, root: false
	    rescue => e
        puts e.message.inspect
        # puts e.backtrace
	    	render_error(e)
	    end

	    private
        def new_organisation
	    		 @new_organisation = Organisation.create!(organisation_params)
           @new_organisation.memberships.create!(user: current_api_user, admin: true)
        end

    	def organisation_params
   			params.require(:organisations).permit(:name, :description)
		  end

    end
  end
end