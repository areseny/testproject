class Membership < ActiveRecord::Base
	validates_uniqueness_of :user_id, scope: [:organisation_id] 
	validates_presence_of :user, :organisation
	belongs_to :user
	belongs_to :organisation
end