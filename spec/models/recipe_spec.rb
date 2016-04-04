require 'rails_helper'

RSpec.describe Recipe, type: :model do

  describe 'model validations' do

    it 'has a valid factory' do
      expect(FactoryGirl.build(:recipe)).to be_valid
    end

    expects_to_be_invalid_without :recipe, :name, :user, :active


  end
end