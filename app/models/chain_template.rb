class ChainTemplate < ActiveRecord::Base

  belongs_to :user
  has_many :step_templates, inverse_of: :chain_template

  validates_presence_of :name, :user
  validates_inclusion_of :active, :in => [true, false]
  validate :steps_have_unique_positions, :all_steps_present?

  after_initialize :set_as_active

  scope :active, -> { where(active: true) }

  def generate_step_templates(data)
    generate_steps_with_positions(data[:steps_with_positions]) if data[:steps_with_positions].present?
    generate_steps(data[:steps]) if data[:steps].present?
  end

  private

  def generate_steps_with_positions(step_template_data)
    # [ {position: 1, name: "DocxToXml"}, {position: 2, name: "XmlToHtml" } ]
    return unless step_template_data.present?
    step_template_data.each do |st|
      step_templates.new(position: st[:position], step_class: StepClass.find_by_name(st[:name]))
    end
  end

  def generate_steps(step_template_data)
    # [ "DocxToXml", "XmlToHtml" ]
    return unless step_template_data.present?
    count = 0
    step_template_data.each do |step_class_name|
      count += 1
      ste = step_templates.new(position: count, step_class: StepClass.find_by_name(step_class_name))
    end
  end

  def set_as_active
    attributes[:active] = true if active.nil?
  end

  def steps_have_unique_positions
    # necessary since it's possible none will have been committed to the db yet!

    positions = step_templates.map(&:position)
    duplicates = positions.detect{ |e| positions.count(e) > 1 }
    errors.add(:step_template_positions, "must be unique") if duplicates
  end

  def all_steps_present?
    array = step_templates.map(&:position)
    contiguous = array.sort.each_cons(2).all? { |x,y| y == x + 1 }
    errors.add(:step_template_positions, "must be contiguous") unless contiguous
  end

end