class AddStartFinishTimesToSteps < ActiveRecord::Migration[5.0]
  def change
    add_column :process_steps, :started_at, :datetime
    add_column :process_steps, :finished_at, :datetime

    ProcessStep.all.each do |step|
      step.update_attribute(:started_at, step.process_chain.executed_at)
      step.update_attribute(:finished_at, step.process_chain.finished_at)
    end
  end
end
