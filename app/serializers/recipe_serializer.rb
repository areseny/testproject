class RecipeSerializer < ActiveModel::Serializer

  # has_many :recipe_steps

  attributes :id, :name, :description, :active, :account_id, :executeRecipeInProgress, :public, :process_chains, :recipe_steps

  def recipe_steps
    object.recipe_steps.order(position: :asc).map{|recipe_step| ActiveModelSerializers::SerializableResource.new(recipe_step, adapter: :attribute).as_json}
  end

  def process_chains
    account_id = @instance_options[:account_id]
    object.process_chains.belongs_to_account(account_id).order(executed_at: :desc).map{|chain| ActiveModelSerializers::SerializableResource.new(chain, adapter: :attribute).as_json}
  end

  def executeRecipeInProgress
    object.execute_recipe_in_progress?
  end

end