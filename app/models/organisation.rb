class Organisation < ActiveRecord::Base
	validates_presence_of :name
	validates :name, uniqueness: true
	has_many :memberships

end
