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

end