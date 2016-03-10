class ChainTemplateSerializer < ActiveModel::Serializer

  has_many :step_templates

  attributes :id, :name, :description, :active

end