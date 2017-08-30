class RecipeSerializer < ActiveModel::Serializer

  has_many :recipe_steps, serializer: RecipeStepSerializer
  has_many :process_chains, serializer: ProcessChainSerializer do
    if scope.admin?
      object.process_chains.take(25)
    else
      object.process_chains.where(account_id: scope.account.id)
    end
  end

  attributes :id, :name, :description, :active, :account_id, :executeRecipeInProgress, :public, :process_chains, :recipe_steps

  def executeRecipeInProgress
    object.execute_recipe_in_progress?
  end

end