class Membership < ActiveRecord::Base
	validates_uniqueness_of :organisation, {scope: :user}
	validates_presence_of :user, :organisation
	belongs_to :user
	belongs_to :organisation

end
