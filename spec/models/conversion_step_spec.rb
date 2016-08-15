require 'rails_helper'

RSpec.describe Conversion::Steps::ConversionStep, type: :model do

  describe 'model validations' do

    it 'has a valid factory' do
      expect(FactoryGirl.build(:conversion_step)).to be_valid
    end

    expects_to_be_invalid_without :conversion_step, :conversion_chain, :position

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

      it 'should be unique to that recipe / position combination' do
        recipe = FactoryGirl.create(:conversion_chain)
        FactoryGirl.create(:conversion_step, conversion_chain: recipe, position: 1)
        expect(FactoryGirl.build(:conversion_step, conversion_chain: recipe, position: 1)).to_not be_valid
      end

    end
  end

  describe '#is_text_file?' do
    let(:html_file)         { fixture_file_upload('files/test.html', 'text/html') }
    let(:photo_file)         { fixture_file_upload('files/kitty.jpeg', 'image/jpeg') }
    subject { Conversion::Steps::ConversionStep.new }

    specify do
      expect(subject.is_text_file?(html_file)).to be true
      expect(subject.is_text_file?(photo_file)).to be false
    end
  end
end