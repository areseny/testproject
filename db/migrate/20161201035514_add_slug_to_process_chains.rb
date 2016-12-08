require 'ink_step/mixins/helper_methods'

class AddSlugToProcessChains < ActiveRecord::Migration[5.0]
  include InkStep::Mixins::HelperMethods

  def change
    add_column :process_chains, :slug, :string

    ProcessChain.all.each do |chain|
      while ProcessChain.all.map(&:slug).include?(@new_slug) || @new_slug.empty?
        @new_slug = "#{chain.created_at.to_i}_#{random_alphanumeric_string}"
      end
      chain.slug = @new_slug
      chain.save
    end
  end
end
