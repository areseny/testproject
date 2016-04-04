require 'rails_helper'

RSpec.describe ConversionChain, type: :model do

  describe 'model validations' do

    it 'has a valid factory' do
      expect(FactoryGirl.build(:conversion_chain)).to be_valid
    end

    expects_to_be_invalid_without :conversion_chain, :user, :recipe
  end

end