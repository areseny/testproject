require 'rails_helper'

RSpec.describe Organisation, type: :model do

  describe 'model validations' do

    it 'has a valid factory' do
      expect(FactoryGirl.build(:organisation)).to be_valid
    end

    expects_to_be_invalid_without :organisation, :name
  end
end