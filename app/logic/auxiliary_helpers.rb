require 'securerandom'
require 'base64'

module AuxiliaryHelpers

  def snake_case_to_camel_case
    class_name.split('_').collect(&:capitalize).join
  end

  def class_name
    self.class.name.split('::').last
  end

  def random_alphanumeric_string
    Base64.encode64(SecureRandom.uuid)[0..10]
  end
end

class String
  # ruby mutation methods have the expectation to return self if a mutation occurred, nil otherwise.
  # (see http://www.ruby-doc.org/core-1.9.3/String.html#method-i-gsub-21)

  def to_underscore!
    gsub!(/(.)([A-Z])/,'\1_\2')
    downcase!
  end

  def to_underscore
    dup.tap { |s| s.to_underscore! }
  end
end