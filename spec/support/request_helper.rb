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
end