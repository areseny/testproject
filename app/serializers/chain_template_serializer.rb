class ChainTemplateSerializer < ActiveModel::Serializer

  has_many :step_templates

  attributes :id, :name, :description, :active, :times_executed

end