class RecipeSerializer < ActiveModel::Serializer

  has_many :recipe_steps
  has_many :conversion_chains

  attributes :id, :name, :description, :active, :times_executed, :user_id, :executeRecipeInProgress, :public

  def executeRecipeInProgress
    object.execute_recipe_in_progress?
  end

end