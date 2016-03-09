require 'rails_helper'

RSpec.describe ChainTemplate, type: :model do

  describe 'model validations' do

    it 'has a valid factory' do
      expect(FactoryGirl.build(:chain_template)).to be_valid
    end

    expects_to_be_invalid_without :chain_template, :name, :user, :active


  end
end