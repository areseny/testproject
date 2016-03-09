require 'spec_helper'

########## INTEGRATION TEST REQUEST TEMPLATES ###########
# These are basically here to prevent too much copy-pasting of code when the API version changes.
# They only work for integration tests, NOT controller tests.

def create_chain_template_request(version, auth_headers, data = {}.to_json)
  post "/api/chain_templates", data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end

def index_chain_template_request(version, auth_headers)
  get "/api/chain_templates", {}, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end

def show_chain_template_request(version, auth_headers, id)
  get "/api/chain_templates/#{id}", {}, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end

def archive_chain_template_request(version, auth_headers, id)
  delete "/api/chain_templates/#{id}", {}, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end
