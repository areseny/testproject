require 'rails_helper'

RSpec.describe StepTemplate, type: :model do

  describe 'model validations' do

    it 'has a valid factory' do
      expect(FactoryGirl.build(:step_template)).to be_valid
    end

    expects_to_be_invalid_without :step_template, :chain_template, :position

    describe 'position' do
      it 'should be an integer' do
        expect(FactoryGirl.build(:step_template, position: 2.4)).to_not be_valid
      end

      it 'should be positive' do
        expect(FactoryGirl.build(:step_template, position: -2)).to_not be_valid
      end

      it 'should be greater than 0' do
        expect(FactoryGirl.build(:step_template, position: 0)).to_not be_valid
      end

      it 'should be greater than 0' do
        expect(FactoryGirl.build(:step_template, position: 1)).to be_valid
      end

      it 'should be unique to that chain template / position combination' do
        chain_template = FactoryGirl.create(:chain_template)
        FactoryGirl.create(:step_template, chain_template: chain_template, position: 1)
        expect(FactoryGirl.build(:step_template, chain_template: chain_template, position: 1)).to_not be_valid
      end

    end
  end
end