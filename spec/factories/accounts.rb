FactoryGirl.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :account, aliases: [:user] do
    name "Fabulous Person or Organisation"
    password "password!"
    password_confirmation "password!"
    email
    confirmed_at Date.today
    factory :unconfirmed_account do
      confirmed_at nil
    end
  end

  factory :account_role, aliases: [:user_role] do
    account
    role "admin"
  end


end