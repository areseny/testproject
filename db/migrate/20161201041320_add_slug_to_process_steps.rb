require 'ink_step/mixins/helper_methods'

class AddSlugToProcessSteps < ActiveRecord::Migration[5.0]
  include InkStep::Mixins::HelperMethods

  def change
    add_column :process_steps, :slug, :string

    ProcessStep.all.each do |chain|
      chain.process_steps.each do |step|
        # find slug, generate if none
        step.generate_unique_slug
        step.save!
      end
    end
  end
end
