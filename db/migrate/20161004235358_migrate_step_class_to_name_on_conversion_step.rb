class MigrateStepClassToNameOnConversionStep < ActiveRecord::Migration
  def up
    add_column :conversion_steps, :step_class_name, :string

    ConversionStep.reset_column_information
    StepClass.reset_column_information

    ConversionStep.all.each do |step|
      name = step.step_class.name
      ap "Changing step #{name}"
      step.update_attribute(:step_class, full_name(name))
      ap "now changed to #{step.reload.step_class_name}"
    end
  end

  def down
    remove_column :conversion_steps, :step_class_name
  end

  def full_name(name)
    return "InkStep::BasicStep" if name == "Step"
    name
  end
end

class ConversionStep < ActiveRecord::Base
  belongs_to :step_class
end

class StepClass < ActiveRecord::Base

end