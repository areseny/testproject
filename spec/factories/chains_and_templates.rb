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

  factory :conversion_chain do
    recipe
    user
    input_file { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'fixtures', 'files', 'test_file.xml')) }
  end

  factory :conversion_step do
    conversion_chain
    position 1
    step_class
    notes "yay! done!"
  end

  factory :step_class do
    sequence :name do |n|
      "Step"
    end
  end

  factory :step_template do
    recipe
    step_class
    position 1
  end

end