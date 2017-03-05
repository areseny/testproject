require 'rails_helper'

RSpec.describe User, type: :model do

  describe 'model validations' do

    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end

    expects_to_be_invalid_without :user, :email, :password
  end

  describe '#add_roles' do

    let!(:user)     { create(:user) }
    let(:new_role)  { "supreme_dictator" }

    context 'if the role does NOT already exist' do
      specify do
        user.add_roles(new_role)

        user.reload

        expect(user.roles).to eq [new_role]
      end
    end

    context 'if the role already exists' do
      before do
        create(:user_role, user: user, role: "absolute_monarch")
        create(:user_role, user: user, role: new_role)
      end

      specify do
        expect{user.add_roles(new_role)}.to_not change{user.roles.count}
      end
    end
  end
end