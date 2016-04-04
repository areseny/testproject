require 'spec_helper'

########## INTEGRATION TEST REQUEST TEMPLATES ###########
# These are basically here to prevent too much copy-pasting of code when the API version changes.
# They only work for integration tests, NOT controller tests.

def create_recipe_request(version, auth_headers, data = {})
  post "/api/recipes", data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end

def update_recipe_request(version, auth_headers, data = {})
  patch "/api/recipes/#{data[:id]}", data.to_json, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end

def index_recipe_request(version, auth_headers)
  get "/api/recipes", {}, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end

def show_recipe_request(version, auth_headers, id)
  get "/api/recipes/#{id}", {}, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end

def archive_recipe_request(version, auth_headers, id)
  delete "/api/recipes/#{id}", {}, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end

def execute_recipe_request(version, auth_headers, data = {})
  id = data[:id]
  data.delete(:id)
  post "/api/recipes/#{id}/execute", data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end
