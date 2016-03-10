class StepTemplate < ActiveRecord::Base

  belongs_to :step_class
  belongs_to :chain_template

  validates_presence_of :chain_template, :step_class, :position
  validates :position, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates_uniqueness_of :position, { scope: :chain_template, message: "Only one step can be in this position for this chain" }

end