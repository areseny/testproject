require_relative 'version'

describe Api::V1::MembershipsController, type: :controller do
  include Devise::TestHelpers
  let!(:user)				{FactoryGirl.create(:user, name: "Terry Ball", password: "password", password_confirmation: "password") }
  let!(:admin_membership)	{FactoryGirl.create(:admin_membership)}
  let!(:membership)			{FactoryGirl.create(:membership)}
 end