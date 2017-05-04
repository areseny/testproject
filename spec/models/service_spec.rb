require 'rails_helper'

RSpec.describe Service, type: :model do

  let!(:account)           { create(:account) }

  describe 'model validations' do

    it 'has a valid factory' do
      expect(build(:service)).to be_valid
    end

    expects_to_be_invalid_without :service, :account, :name
  end

end