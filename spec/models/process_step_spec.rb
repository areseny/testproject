require 'rails_helper'

RSpec.describe ProcessStep, type: :model do

  describe 'model validations' do

    it 'has a valid factory' do
      expect(build(:process_step)).to be_valid
    end

    expects_to_be_invalid_without :process_step, :process_chain, :position, :step_class_name

    describe 'position' do
      it 'is an integer' do
        expect(build(:process_step, position: 2.4)).to_not be_valid
      end

      it 'is positive' do
        expect(build(:process_step, position: -2)).to_not be_valid
      end

      it 'is greater than 0' do
        expect(build(:process_step, position: 0)).to_not be_valid
      end

      it 'is greater than 0' do
        expect(build(:process_step, position: 1)).to be_valid
      end

      it 'is unique to that recipe / position combination' do
        recipe = create(:process_chain)
        create(:process_step, process_chain: recipe, position: 1)
        expect(build(:process_step, process_chain: recipe, position: 1)).to_not be_valid
      end

    end
  end
end