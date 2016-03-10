require 'rails_helper'

RSpec.describe ExecutedChain, type: :model do

  describe 'model validations' do

    it 'has a valid factory' do
      expect(FactoryGirl.build(:executed_chain)).to be_valid
    end

    expects_to_be_invalid_without :executed_chain, :user, :chain_template


  end
end