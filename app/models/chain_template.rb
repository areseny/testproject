class ChainTemplate < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :name, :user, :active

  after_initialize :set_as_active





  private

  def set_as_active
    attributes[:active] = true if active.nil?
  end

end