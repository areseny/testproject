require 'rails_helper'

RSpec.describe Account, type: :model do

  describe 'model validations' do

    it 'has a valid factory' do
      expect(build(:account)).to be_valid
    end

    expects_to_be_invalid_without :account, :email, :password
  end

  describe '#add_roles' do

    let!(:account)     { create(:account) }
    let(:new_role)  { "supreme_dictator" }

    context 'if the role does NOT already exist' do
      specify do
        account.add_roles(new_role)

        account.reload

        expect(account.roles).to eq [new_role]
      end
    end

    context 'if the role already exists' do
      before do
        create(:account_role, account: account, role: "absolute_monarch")
        create(:account_role, account: account, role: new_role)
      end

      specify do
        expect{account.add_roles(new_role)}.to_not change{account.roles.count}
      end
    end
  end

  describe '#is_admin?' do
    let!(:account)     { create(:account) }

    context 'if the account is not an admin' do
      specify do
        expect(account.admin?).to be_falsey
      end
    end

    context 'if the account is an admin' do
      before do
        create(:account_role, account: account, role: "admin")
      end

      specify do
        expect(account.admin?).to be_truthy
      end
    end
  end
end