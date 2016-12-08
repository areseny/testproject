require 'ink_step/mixins/helper_methods'

module SlugMethods
  include InkStep::Mixins::HelperMethods

  def generate_slug
    "#{Time.now.to_i}_#{random_alphanumeric_string}"
  end

  def generate_unique_slug
    raise "Use with ActiveRecord subclass only" unless self.class.respond_to?(:all)
    return if slug.present?
    while @new_slug.nil? || self.class.all.map(&:slug).include?(@new_slug)
      @new_slug = generate_slug
    end
    self.slug = @new_slug
  end

end