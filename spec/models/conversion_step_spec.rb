require 'rails_helper'

RSpec.describe ConversionStep, type: :model do

  describe 'model validations' do

    it 'has a valid factory' do
      expect(FactoryGirl.build(:conversion_step)).to be_valid
    end

    expects_to_be_invalid_without :conversion_step, :executed_chain, :position

    describe 'position' do
      it 'should be an integer' do
        expect(FactoryGirl.build(:conversion_step, position: 2.4)).to_not be_valid
      end

      it 'should be positive' do
        expect(FactoryGirl.build(:conversion_step, position: -2)).to_not be_valid
      end

      it 'should be greater than 0' do
        expect(FactoryGirl.build(:conversion_step, position: 0)).to_not be_valid
      end

      it 'should be greater than 0' do
        expect(FactoryGirl.build(:conversion_step, position: 1)).to be_valid
      end

      it 'should be unique to that chain template / position combination' do
        chain_template = FactoryGirl.create(:executed_chain)
        FactoryGirl.create(:conversion_step, executed_chain: chain_template, position: 1)
        expect(FactoryGirl.build(:conversion_step, executed_chain: chain_template, position: 1)).to_not be_valid
      end

    end
  end
end