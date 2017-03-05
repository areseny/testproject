require 'spec_helper'

############## CONTROLLER TEST REQUEST TEMPLATES #############
# These are for the controller tests.

def request_with_auth(auth_headers = {})
  request.headers.merge!(auth_headers)
  yield
end

def post_create_request(version, data = {}.to_json)
  post :create, params: data, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

def put_update_request(version, data)
  put :update, params: data, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

def get_index_request(version, data = {}.to_json)
  get :index, params: data, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

def get_show_request(version, data = {}.to_json)
  get :show, params: data, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

def delete_destroy_request(version, data = {}.to_json)
  delete :destroy, params: data, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

#### specific to certain controllers

# recipe_controller requests

def execute_recipe(version, data = {}.to_json)
  post :execute, params: data, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

def retry_execution(version, data = {}.to_json)
  get :retry, params: data, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

# process_chain requests

def download_input_file(version, data = {}.to_json)
  get :download_input_file, params: data, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

def download_input_zip(version, data = {}.to_json)
  get :download_input_zip, params: data, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

def download_output_file(version, data = {}.to_json)
  get :download_output_file, params: data, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

def download_output_zip(version, data = {}.to_json)
  get :download_output_zip, params: data, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

# admin_controller requests

def get_users_request(version, data = {}.to_json)
  get :users, params: data, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

def service_accounts_request(version, data = {}.to_json)
  get :service_accounts, params: data, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end