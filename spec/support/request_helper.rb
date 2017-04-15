require 'spec_helper'
# include Warden::Test::Helpers

module RequestHelper

  module JsonHelpers
    def body_as_json
      JSON.parse(response.body)
    end
  end

  def create_logged_in_account
    account = create(:account)
    login(account)
    account
  end

  def login(t)
    login_as t, scope: :account
  end

  def login_account(account = create(:account))
    @request.env["devise.mapping"] = Devise.mappings[:account]
    sign_in account
  end
end