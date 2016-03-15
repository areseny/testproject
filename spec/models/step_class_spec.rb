require 'rails_helper'

RSpec.describe StepClass, type: :model do

  describe 'model validations' do

    it 'has a valid factory' do
      expect(FactoryGirl.build(:step_class)).to be_valid
    end

    expects_to_be_invalid_without :step_class, :name, :active

    it 'should not be valid without a name in the "all_classes" method' do
      expect(FactoryGirl.build(:step_class, name: "nonsense")).to_not be_valid
    end
  end

  describe '#behaviour_class' do

    before do
      expect(StepClass).to receive(:all_steps) { [Conversion::Steps::JpgToPng] }
    end

    it 'should find the correct behavioural class' do
      expect(FactoryGirl.build(:step_class, name: "JpgToPng").behaviour_class).to eq Conversion::Steps::JpgToPng
    end

  end
end