class RecipeSerializer < ActiveModel::Serializer

  has_many :recipe_steps, serializer: RecipeStepSerializer
  has_many :process_chains, serializer: ProcessChainSerializer

  attributes :id, :name, :description, :active, :account_id, :executeRecipeInProgress, :public, :process_chains, :recipe_steps

  def executeRecipeInProgress
    object.execute_recipe_in_progress?
  end

end