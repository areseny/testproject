class RecipeSerializer < ActiveModel::Serializer

  has_many :recipe_steps
  has_many :conversion_chains

  attributes :id, :name, :description, :active, :times_executed, :user_id, :executeRecipeInProgress

  def conversion_chains
    object.conversion_chains.order( 'conversion_chains.executed_at DESC' )
  end

  def executeRecipeInProgress
    object.execute_recipe_in_progress?
  end

end