require 'rails_helper'

RSpec.describe Recipe, type: :model do

  describe 'model validations' do

    it 'has a valid factory' do
      expect(build(:recipe)).to be_valid
    end

    expects_to_be_invalid_without :recipe, :name, :user, :active, :public
  end

  describe 'available recipes to user scope' do

    let!(:user)           { create(:user) }
    let!(:other_user)     { create(:user) }

    let!(:recipe1) { create(:recipe, public: true, user: other_user) }
    let!(:recipe2) { create(:recipe, public: true, user: user) }
    let!(:recipe3) { create(:recipe, public: false, user: user) }
    let!(:recipe4) { create(:recipe, public: false, user: other_user) }

    specify do
      expect(Recipe.available_to_user(user.id)).to match_array([recipe1, recipe2, recipe3])
      expect(Recipe.available_to_user(other_user.id)).to match_array([recipe1, recipe2, recipe4])
    end
  end
end