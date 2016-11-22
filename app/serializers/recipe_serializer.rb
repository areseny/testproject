class RecipeSerializer < ActiveModel::Serializer

  has_many :recipe_steps
  # has_many :process_chains

  attributes :id, :name, :description, :active, :times_executed, :user_id, :executeRecipeInProgress, :public, :process_chains

  def process_chains
    user_id = @instance_options[:user_id]
    object.process_chains.belongs_to_user(user_id).order(executed_at: :desc).map{|chain| ActiveModelSerializers::SerializableResource.new(chain, adapter: :attribute).as_json}
  end

  def executeRecipeInProgress
    object.execute_recipe_in_progress?
  end

end