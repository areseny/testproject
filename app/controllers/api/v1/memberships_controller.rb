module Api
  module V1
    class OrganisationsController < ApplicationController
    	before_action :authenticate_api_user!, only: []

    	respond_to :json

    	
    end
  end
end