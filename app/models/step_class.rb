class StepClass < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_inclusion_of :active, in: [true, false]

  after_initialize :set_as_active

  scope :active, -> { where(active: true) }

  def self.find_by_name(value)
    where("lower(name) = ?", value.downcase).first
  end

  private

  def set_as_active
    attributes[:active] = true if active.nil?
  end

end