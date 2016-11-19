FactoryGirl.define do

  factory :recipe do
    name "PNG to JPG transmogrifier"
    description "This will allow me to input a PNG and get out a JPG! It's magic!"
    user
    active true
    factory :archived_recipe do
      active false
    end
  end

  factory :process_chain do
    recipe
    user
    input_file { File.new(File.join(Rails.root, 'spec', 'fixtures', 'files', 'test_file.xml')) }
  end

  factory :conversion_step do
    process_chain
    position 1
    step_class_name "InkStep::BasicStep"
    notes "yay! done!"
    output_file { File.new('spec/fixtures/files/test_file.xml', 'r') }
    factory :executed_conversion_step_success do
      executed_at 2.minutes.ago
      output_file { File.new(File.join(Rails.root, 'spec', 'fixtures', 'files', 'test_file.xml')) }
    end
    factory :executed_conversion_step_fail do
      executed_at 2.minutes.ago
      output_file nil
      execution_errors ["Very Serious Error"].to_yaml
    end
    version "0.1"
  end

  factory :recipe_step do
    recipe
    step_class_name "InkStep::BasicStep"
    position 1
  end

end