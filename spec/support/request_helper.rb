require 'spec_helper'
# include Warden::Test::Helpers

module RequestHelper

  module JsonHelpers
    def body_as_json
      JSON.parse(response.body)
    end
  end

  def create_logged_in_user
    user = FactoryGirl.create(:user)
    login(user)
    user
  end

  def login(t)
    login_as t, scope: :user
  end

  def login_user(user = FactoryGirl.create(:user))
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
  end

  ########## INTEGRATION TEST REQUEST TEMPLATES ###########
  # These are basically here to prevent too much copy-pasting of code when the API version changes.
  # They only work for integration tests, NOT controller tests.

  def create_chain_template_request(version, auth_headers, data = {}.to_json)
    post "/api/chain_templates", data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
  end

  def index_chain_template_request(version, auth_headers, data = {}.to_json)
    get "/api/chain_templates", data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
  end

  def sign_in_request(version, params = {}.to_json)
    post "/api/auth/sign_in", params, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
  end

  def sign_out_request(version, auth_headers, params = {}.to_json)
    delete "/api/auth/sign_out", params, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
  end

  def sign_up_request(version, params = {}.to_json)
    post "/api/auth/", params, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
  end

  ############## CONTROLLER TEST REQUEST TEMPLATES #############
  # These are for the controller tests.

  def create_chain_template(version, auth_headers, data = {}.to_json)
    post :create, data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
  end

  def index_chain_template(version, auth_headers, data = {}.to_json)
    get :index, data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
  end


end