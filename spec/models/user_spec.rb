require 'rails_helper'

RSpec.describe User, type: :model do

  describe 'model validations' do

    it 'has a valid factory' do
      expect(FactoryGirl.build(:user)).to be_valid
    end

    expects_to_be_invalid_without :user, :email, :password


  end
end