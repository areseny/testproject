require 'rails_helper'

RSpec.describe UserRole, type: :model do

  let!(:user)           { create(:user) }

  describe 'model validations' do

    it 'has a valid factory' do
      expect(build(:user_role)).to be_valid
    end

    expects_to_be_invalid_without :user_role, :user, :role

    it 'is invalid if the user already has that role' do
      create(:user_role, user: user, role: "worker")
      new_user_role = build(:user_role, user: user, role: "worker")

      expect(new_user_role).to_not be_valid
    end
  end
end