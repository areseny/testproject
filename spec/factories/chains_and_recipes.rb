require 'constants'
require_relative '../step_class_constants'

FactoryGirl.define do

  factory :recipe do
    name "PNG to JPG transmogrifier"
    description "This will allow me to input a PNG and get out a JPG! It's magic!"
    user
    active true
    factory :archived_recipe do
      active false
    end

    # the after(:create) yields two values; the user instance itself and the
    # evaluator, which stores all values from the factory, including transient
    # attributes; `create_list`'s second argument is the number of records
    # to create and we make sure the user is associated properly to the post
    after(:build) do |recipe, evaluator|
      recipe.recipe_steps.new(step_class_name: base_step_class, position: 1)
    end
  end

  factory :process_chain do
    recipe
    user
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
      output_file nil
      execution_errors ["Very Serious Error"].to_yaml
    end
    version "0.1"
  end

  factory :recipe_step do
    recipe
    step_class_name InkStep::ConversionStep.to_s
    position 1
  end

end