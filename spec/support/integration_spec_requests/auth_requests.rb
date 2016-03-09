require 'spec_helper'

### AUTH REQUESTS ###

def sign_in_request(version, data = {}.to_json)
  post "/api/auth/sign_in", data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

def sign_out_request(version, auth_headers, params = {}.to_json)
  delete "/api/auth/sign_out", params, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }.merge(auth_headers)
end

def sign_up_request(version, params = {}.to_json)
  post "/api/auth/", params, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end
