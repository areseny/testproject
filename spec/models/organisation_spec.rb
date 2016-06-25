require 'rails_helper'

RSpec.describe Organisation, type: :model do

  describe 'model validations' do

    let(:name)  { "random number company 2321412" }

    it 'has a valid factory' do
      expect(FactoryGirl.build(:organisation)).to be_valid
    end

    it "does not allow duplicate organisation names" do
    	FactoryGirl.create(:organisation, name: name)
    	expect(FactoryGirl.build(:organisation, name: name)).to_not be_valid
    end

    expects_to_be_invalid_without :organisation, :name

  end
end
