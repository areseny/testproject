# create_table "recipe_steps", force: :cascade do |t|
#   t.integer  "recipe_id", null: false
#   t.integer  "position",          null: false
#   t.datetime "created_at",        null: false
#   t.datetime "updated_at",        null: false
#   t.string  "step_class_name",    null: false
# end

class RecipeStep < ApplicationRecord
  include ObjectMethods

  belongs_to :recipe, inverse_of: :recipe_steps

  validates_presence_of :recipe, :position, :step_class_name
  validates :position, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates_uniqueness_of :position, { scope: :recipe, message: "Only one step can be in this position for this chain" }

  def step_class
    class_from_string(step_class_name)
  end

end