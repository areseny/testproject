require 'spec_helper'

########## INTEGRATION TEST REQUEST TEMPLATES ###########
# These are basically here to prevent too much copy-pasting of code when the API version changes.
# They only work for integration tests, NOT controller tests.

def index_step_class_request(version, auth_headers)
  get "/api/available_step_classes", params: {}, headers: {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end
