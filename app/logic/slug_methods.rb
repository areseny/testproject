require 'ink_step/mixins/helper_methods'

module SlugMethods
  include InkStep::Mixins::HelperMethods

  def generate_slug
    "#{Time.now.to_i}_#{random_alphanumeric_string}"
  end

  def generate_unique_slug
    @all_chain_slugs ||= ProcessChain.all.map(&:slug)
    ap "All slugs:"
    ap @all_chain_slugs.uniq
    return if slug.present?
    ap "Slug not present"
    while @new_slug.nil? || slug_not_unique?
      ap "Looping: new slug nil? #{@new_slug.nil?}"
      ap "Looping: slug not unique? #{slug_not_unique?}"
      @new_slug = generate_slug
      ap "Slug for #{self.id} generated: `#{@new_slug}`"
    end
    ap "out of loop"
    self.slug = @new_slug
  end

  def slug_not_unique?
    @all_process_chains.include?(@new_slug)
  end

end