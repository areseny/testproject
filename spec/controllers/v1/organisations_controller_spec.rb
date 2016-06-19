require_relative 'version'

describe Api::V1::OrganisationsController, type: :controller do
  include Devise::TestHelpers
  let!(:user)			{ FactoryGirl.create(:user, password: "password", password_confirmation: "password") }
  let!(:organisation)	{FactoryGirl.create(:organisation)}

 end