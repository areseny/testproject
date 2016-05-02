# create_table "step_classes", force: :cascade do |t|
#   t.string   "name",                      null: false
#   t.boolean  "active",     default: true, null: false
#   t.datetime "created_at",                null: false
#   t.datetime "updated_at",                null: false
# end

class StepClass < ActiveRecord::Base

  validates_presence_of :name
  validates_inclusion_of :active, in: [true, false]
  validate :name_included_in_all_steps?

  after_initialize :set_as_active

  scope :active, -> { where(active: true) }

  def self.find_by_name(value)
    where("lower(name) = ?", value.downcase).first
  end

  def behaviour_class
    matching_classes = StepClass.all_steps.select{|class_name| class_name.name.demodulize == name}
    matching_classes.first
  end

  def self.all_steps
    [Conversion::Steps::FlipImage,
     Conversion::Steps::DocxToHtml,
     Conversion::Steps::XmlToHtml,
     Conversion::Steps::DocxToXml,
     Conversion::Steps::JpgToPng,
     Conversion::Steps::Step]
  end

  private

  def set_as_active
    attributes[:active] = true if active.nil?
  end

  def name_included_in_all_steps?
    return if behaviour_class.present?
    errors[:name] << "#{name} is not included in the behaviour step list"
  end

end