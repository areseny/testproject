require 'rails_helper'

RSpec.describe ConversionStep, type: :model do

  describe 'model validations' do

    it 'has a valid factory' do
      expect(build(:conversion_step)).to be_valid
    end

    expects_to_be_invalid_without :conversion_step, :conversion_chain, :position, :step_class_name

    describe 'position' do
      it 'should be an integer' do
        expect(build(:conversion_step, position: 2.4)).to_not be_valid
      end

      it 'should be positive' do
        expect(build(:conversion_step, position: -2)).to_not be_valid
      end

      it 'should be greater than 0' do
        expect(build(:conversion_step, position: 0)).to_not be_valid
      end

      it 'should be greater than 0' do
        expect(build(:conversion_step, position: 1)).to be_valid
      end

      it 'should be unique to that recipe / position combination' do
        recipe = create(:conversion_chain)
        create(:conversion_step, conversion_chain: recipe, position: 1)
        expect(build(:conversion_step, conversion_chain: recipe, position: 1)).to_not be_valid
      end

    end
  end
end