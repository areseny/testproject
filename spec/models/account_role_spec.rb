require 'rails_helper'

RSpec.describe AccountRole, type: :model do

  let!(:account)           { create(:account) }

  describe 'model validations' do

    it 'has a valid factory' do
      expect(build(:account_role)).to be_valid
    end

    expects_to_be_invalid_without :account_role, :account, :role

    it 'is invalid if the account already has that role' do
      create(:account_role, account: account, role: "worker")
      new_account_role = build(:account_role, account: account, role: "worker")

      expect(new_account_role).to_not be_valid
    end
  end
end