require 'spec_helper'

############## CONTROLLER TEST REQUEST TEMPLATES #############
# These are for the controller tests.

def request_with_auth(auth_headers = {})
  request.headers.merge!(auth_headers)
  yield
end

def post_create_request(version, data = {}.to_json)
  post :create, data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

def put_update_request(version, data)
  put :update, data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

def patch_update_request(version, data)
  patch :update, data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

def get_index_request(version, data = {}.to_json)
  get :index, data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

def get_show_request(version, data = {}.to_json)
  get :show, data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

def delete_destroy_request(version, data = {}.to_json)
  delete :destroy, data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

#### specific to certain controllers

# chain_template_controller requests

def execute_chain_template(version, data = {}.to_json)
  post :execute, data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

