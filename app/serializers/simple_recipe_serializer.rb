class SimpleRecipeSerializer < ActiveModel::Serializer

  attributes :id, :name, :description, :active, :account_id, :public, :recipe_steps, :favourite

  def favourite
    object.favourited_by?(scope)
  end

end