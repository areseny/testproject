require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user)				{FactoryGirl.create(:user, name: "Odie the Dog") }
  let!(:super_admin_user)	{FactoryGirl.create(:user, name: "Nermal the Kitten", super_user: true) }
  let!(:the_organisation)	{FactoryGirl.create(:organisation)}
  let!(:other_organisation)	{FactoryGirl.create(:organisation, name: "Cats Incorporated")}

  describe 'model validations' do

    it 'has a valid factory' do
      expect(FactoryGirl.build(:user)).to be_valid
    end

    expects_to_be_invalid_without :user, :email, :password



  end
  describe 'is_admin?' do

  	it 'is an admin of this org' do
  		FactoryGirl.create(:membership, user: user, organisation: the_organisation, admin: true)
  		expect(user.is_admin?(the_organisation)).to be true
  	end
  	it 'is a user not admin of this org' do
  		FactoryGirl.create(:membership, user: user, organisation: the_organisation, admin: false)
  		expect(user.is_admin?(the_organisation)).to be false
  	end
	it 'is an admin of a different org' do
		FactoryGirl.create(:membership, user: user, organisation: other_organisation, admin: true)
  		expect(user.is_admin?(the_organisation)).to be false
	end
  	it 'is a user of a different org' do
  		FactoryGirl.create(:membership, user: user, organisation: other_organisation, admin: false)
  		expect(user.is_admin?(the_organisation)).to be false
  	end
  	it 'is none of the above' do 
  		expect(user.is_admin?(the_organisation)).to be false 
  	end
  end

  describe 'super_user?' do

  	it 'is a super user' do
  		expect(super_admin_user.super_user?).to be true 
  	end
  	it 'is not a super user' do
  		expect(user.super_user?).to be false 
  	end
  end

end