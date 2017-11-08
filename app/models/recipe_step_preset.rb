class RecipeStepPreset < ApplicationRecord

  belongs_to :recipe_step, inverse_of: :recipe_step_presets
  belongs_to :account, inverse_of: :recipe_step_presets

  validates_presence_of :recipe_step, :name, :account

end