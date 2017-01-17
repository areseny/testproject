require 'ink_step/mixins/helper_methods'

module SlugMethods
  include InkStep::Mixins::HelperMethods

  def generate_slug
    "#{Time.now.to_i}_#{random_alphanumeric_string}"
  end

  def generate_unique_slug
    return if slug.present?
    while @new_slug.nil? || slug_not_unique?
      @new_slug = generate_slug
      ap "Slug for #{self.id} generated: `#{@new_slug}`"
      ap "Slug already exists? #{slug_not_unique?}"
    end
    self.slug = @new_slug
  end

  def slug_not_unique?
    ProcessChain.all.map(&:slug).include?(@new_slug)
  end

end