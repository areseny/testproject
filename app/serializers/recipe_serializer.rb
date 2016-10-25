class RecipeSerializer < ActiveModel::Serializer

  has_many :recipe_steps
  # has_many :conversion_chains

  attributes :id, :name, :description, :active, :times_executed, :user_id, :executeRecipeInProgress, :public, :conversion_chains

  def conversion_chains
    object.conversion_chains.order(executed_at: :desc).map{|chain| ActiveModelSerializers::SerializableResource.new(chain, adapter: :attribute).as_json}
  end

  def executeRecipeInProgress
    object.execute_recipe_in_progress?
  end

end