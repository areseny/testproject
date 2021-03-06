require 'spec_helper'

########## INTEGRATION TEST REQUEST TEMPLATES ###########
# These are basically here to prevent too much copy-pasting of code when the API version changes.
# They only work for integration tests, NOT controller tests.

def create_recipe_request(version, auth_headers, data = {})
  post "/api/recipes", params: data, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end

def update_recipe_request(version, auth_headers, data = {})
  put "/api/recipes/#{data[:id]}", params: data.to_json, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end

def index_recipe_request(version, auth_headers)
  get "/api/recipes", params: {}, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end

def show_recipe_request(version, auth_headers, id)
  get "/api/recipes/#{id}", params: {}, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end

def archive_recipe_request(version, auth_headers, id)
  delete "/api/recipes/#{id}", params: {}, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end

def favourite_recipe_request(version, auth_headers, id)
  get "/api/recipes/#{id}/favourite", params: {}, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end

def unfavourite_recipe_request(version, auth_headers, id)
  get "/api/recipes/#{id}/unfavourite", params: {}, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end

def execute_recipe_request(version, auth_headers, data = {})
  id = data[:id]
  data.delete(:id)
  post "/api/recipes/#{id}/execute", params: data, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end

def index_all_recipes_request(version, auth_headers)
  get "/api/recipes/index-all", params: {}, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end
