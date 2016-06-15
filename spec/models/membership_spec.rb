require 'rails_helper'

RSpec.describe Membership, type: :model do

  describe 'model validations' do

    it 'has a valid factory' do
      expect(FactoryGirl.build(:membership)).to be_valid
    end

    expects_to_be_invalid_without :membership, :user, :organisation
  end
end