FactoryGirl.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :user do
    name "User McFabulous"
    password "password!"
    password_confirmation "password!"
    email
    confirmed_at Date.today
    factory :unconfirmed_user do
      confirmed_at nil
    end
  end

  factory :chain_template do
    name "PNG to JPG transmogrifier"
    description "This will allow me to input a PNG and get out a JPG! It's magic!"
    user
    active true
  end


end