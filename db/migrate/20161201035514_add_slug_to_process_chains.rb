require 'ink_step/mixins/helper_methods'

class AddSlugToProcessChains < ActiveRecord::Migration[5.0]
  include InkStep::Mixins::HelperMethods

  def change
    add_column :process_chains, :slug, :string

    ProcessChain.all.each do |chain|
      chain.save!
    end
  end
end
