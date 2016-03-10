FactoryGirl.define do

  factory :chain_template do
    name "PNG to JPG transmogrifier"
    description "This will allow me to input a PNG and get out a JPG! It's magic!"
    user
    active true
    factory :archived_chain_template do
      active false
    end
  end

  factory :executed_chain do
    chain_template
    user
  end

  factory :conversion_step do
    executed_chain
    position 1
    step_class
    notes "yay! done!"
  end

  factory :step_class do
    sequence :name do |n|
      "PngToJpg#{n}"
    end
  end

  factory :step_template do
    chain_template
    step_class
    position 1
  end

end