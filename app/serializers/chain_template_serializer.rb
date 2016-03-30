class ChainTemplateSerializer < ActiveModel::Serializer

  has_many :step_templates
  has_many :conversion_chains

  attributes :id, :name, :description, :active, :times_executed, :user_id

end