require 'ink_step/mixins/helper_methods'

class AddSlugToProcessChains < ActiveRecord::Migration[5.0]
  include InkStep::Mixins::HelperMethods

  def change
    add_column :process_chains, :slug, :string

    ProcessChain.all.each do |chain|
      # find slug, generate if none
      chain.generate_unique_slug
      chain.save!
    end
  end
end
