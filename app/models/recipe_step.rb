class RecipeStep < ApplicationRecord
  include ObjectMethods

  belongs_to :recipe, inverse_of: :recipe_steps
  has_many :recipe_step_presets, inverse_of: :recipe_step

  validates_presence_of :recipe, :position, :step_class_name
  validates :position, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates_uniqueness_of :position, { scope: :recipe, message: "Only one step can be in this position for this recipe" }

  def step_class
    class_from_string(step_class_name)
  end

end