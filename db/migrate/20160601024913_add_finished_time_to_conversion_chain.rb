class AddFinishedTimeToConversionChain < ActiveRecord::Migration
  def change
    add_column :conversion_chains, :finished_at, :datetime
  end
end
