require 'conversion_errors/conversion_errors'

# create_table "recipes", force: :cascade do |t|
#   t.integer  "user_id",                    null: false
#   t.string   "name",                       null: false
#   t.text     "description"
#   t.boolean  "active",      default: true, null: false
#   t.datetime "created_at",                 null: false
#   t.datetime "updated_at",                 null: false
# end

class Recipe < ActiveRecord::Base
  include ConversionErrors

  belongs_to :user
  has_many :recipe_steps, inverse_of: :recipe
  has_many :conversion_chains

  validates_presence_of :name, :user
  validates_inclusion_of :active, :in => [true, false]
  validate :steps_have_unique_positions, :steps_contiguous?

  after_initialize :set_as_active

  scope :active, -> { where(active: true) }

  def clone_to_conversion_chain(input_file)
    raise ConversionErrors::NoFileSuppliedError unless input_file
    new_chain = conversion_chains.new(user: user, input_file: input_file)
    recipe_steps.each do |recipe_step|
      new_chain.conversion_steps.new(position: recipe_step.position, step_class: recipe_step.step_class)
    end
    new_chain
  end

  def generate_recipe_steps(data)
    generate_steps_with_positions(data[:steps_with_positions]) if data[:steps_with_positions].present?
    generate_steps(data[:steps]) if data[:steps].present?
  end

  def times_executed
    conversion_chains.count
  end

  private

  def generate_steps_with_positions(recipe_step_data)
    # [ {position: 1, name: "DocxToXml"}, {position: 2, name: "XmlToHtml" } ]
    return unless recipe_step_data.present?
    recipe_step_data.each do |st|
      recipe_steps.new(position: st[:position], step_class: StepClass.find_by_name(st[:name]))
    end
  end

  def generate_steps(recipe_step_data)
    # [ "DocxToXml", "XmlToHtml" ]
    return unless recipe_step_data.present?
    count = 0
    recipe_step_data.each do |step_class_name|
      count += 1
      ste = recipe_steps.new(position: count, step_class: StepClass.find_by_name(step_class_name))
    end
  end

  def set_as_active
    attributes[:active] = true if active.nil?
  end

  def steps_have_unique_positions
    # necessary since it's possible none will have been committed to the db yet!

    positions = recipe_steps.map(&:position)
    duplicates = positions.detect{ |e| positions.count(e) > 1 }
    errors.add(:recipe_step_positions, "must be unique") if duplicates
  end

  def steps_contiguous?
    array = recipe_steps.map(&:position)
    contiguous = array.sort.each_cons(2).all? { |x,y| y == x + 1 }
    errors.add(:recipe_step_positions, "must be contiguous") unless contiguous
  end

end