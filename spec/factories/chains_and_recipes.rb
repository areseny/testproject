require 'constants'
require_relative '../step_class_constants'

FactoryGirl.define do

  factory :recipe do
    name "PNG to JPG transmogrifier"
    description "magical and mysterious"
    account
    active true
    factory :archived_recipe do
      active false
    end
    transient do
      step_classes { [base_step_class.to_s] }
    end

    # the after(:create) yields two values; the account instance itself and the
    # evaluator, which stores all values from the factory, including transient
    # attributes; `create_list`'s second argument is the number of records
    # to create and we make sure the account is associated properly to the post
    after(:build) do |recipe, evaluator|
      evaluator.step_classes.each_with_index do |klass, index|
        recipe.recipe_steps.new(step_class_name: klass, position: index+1)
      end
    end
  end

  factory :process_chain do
    recipe
    account
    input_file_list ["asdf.html" => "123kb"]
  end

  factory :process_step do
    process_chain
    position 1
    step_class_name InkStep::ConversionStep.to_s
    notes "yay! done!"
    factory :executed_process_step_success do
      executed_at 2.minutes.ago
    end
    factory :executed_process_step_fail do
      executed_at 2.minutes.ago
      output_file_manifest []
      execution_errors ["Very Serious Error"].to_yaml
    end
    version "0.1"
    output_file_list ["asdf.html" => "123kb"]
  end

  factory :recipe_step do
    recipe
    step_class_name InkStep::ConversionStep.to_s
    position 1
  end

  factory :recipe_step_preset do
    recipe_step
    name "the magic sauce"
    description "very secret"
    account
  end

  factory :recipe_favourite do
    recipe
    account
  end

  factory :single_step_execution do
    account
    description "just by itself!"
    step_class_name "InkStep::AwesomeClass"
    execution_parameters {}
  end

end