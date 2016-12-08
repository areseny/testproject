require 'ink_step/mixins/helper_methods'

class AddSlugToProcessSteps < ActiveRecord::Migration[5.0]
  include InkStep::Mixins::HelperMethods

  def change
    add_column :process_steps, :slug, :string

    ProcessStep.all.each do |step|
      while ProcessStep.all.map(&:slug).include?(@new_slug) || @new_slug.empty?
        @new_slug = "#{step.created_at.to_i}_#{random_alphanumeric_string}"
      end
      step.slug = @new_slug
      step.save
    end
  end
end
