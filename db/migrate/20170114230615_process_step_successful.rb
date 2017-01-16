class ProcessStepSuccessful < ActiveRecord::Migration[5.0]
  def change
    add_column :process_steps, :successful, :boolean

    ProcessStep.connection.schema_cache.clear!
    ProcessStep.reset_column_information

    ProcessStep.all.each do |step|
      step.update_attribute(:successful, get_value(step))
    end
  end

  def get_value(step)
    if step.errors.any?
      return false
    elsif step.process_chain.finished_at.nil?
      return nil
    end

    step.process_chain.process_steps.each do |other_step|
      return nil if other_step.errors.any? && other_step.position < step.position
    end

    true
  end
end
