class ConversionChainSerializer < ActiveModel::Serializer

  has_many :conversion_steps

  attributes :id, :chain_template_id, :executed_at, :input_file_name, :output_file

  def executed_at
    object.executed_at.iso8601
  end

end