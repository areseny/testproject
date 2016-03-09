class ChainTemplate < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :name, :user
  validates_inclusion_of :active, :in => [true, false]

  after_initialize :set_as_active

  scope :active, -> { where(active: true) }

  private

  def set_as_active
    attributes[:active] = true if active.nil?
  end

end