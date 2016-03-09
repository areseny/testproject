require 'spec_helper'

############## CONTROLLER TEST REQUEST TEMPLATES #############
# These are for the controller tests.

def create_chain_template(version, data = {}.to_json)
  post :create, data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

def update_chain_template(version, data)
  put :update, data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

def patch_chain_template(version, id_hash, data)
  patch :update, id_hash, data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

def index_chain_template(version, data = {}.to_json)
  get :index, data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

def show_chain_template(version, data = {}.to_json)
  get :show, data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end

def archive_chain_template(version, data = {}.to_json)
  delete :destroy, data, {'Content-Type' => "application/json", 'Accept' => "application/vnd.ink.#{version}" }
end
