class RecipeFavourite < ApplicationRecord

  belongs_to :recipe, inverse_of: :recipe_favourites
  belongs_to :account, inverse_of: :recipe_favourites

  validates_presence_of :recipe, :account
  validates_uniqueness_of :recipe, { scope: :account, message: "this account already has this recipe favourited" }

end