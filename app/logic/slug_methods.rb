require 'ink_step/mixins/helper_methods'

module SlugMethods
  include InkStep::Mixins::HelperMethods

  def generate_slug
    "#{Time.now.to_i}_#{random_alphanumeric_string}"
  end

  def generate_unique_slug
    return if slug.present?
    while @new_slug.nil? || slug_not_unique?(ProcessChain) || slug_not_unique?(ProcessStep)
      @new_slug = generate_slug
    end
    self.slug = @new_slug
  end

  def slug_not_unique?(klass)
    klass.all.map(&:slug).include?(@new_slug)
  end

end