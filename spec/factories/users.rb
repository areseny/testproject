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
end