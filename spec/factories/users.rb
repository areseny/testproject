FactoryGirl.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end
  

  factory :user do
    name "User McFabulous"
    password "password!"
    password_confirmation "password!"
    email
    super_user false
    confirmed_at Date.today
    factory :unconfirmed_user do
      confirmed_at nil
    end
  end

  factory :organisation do
    # sequence :name do |n|
    #   "Random Number Company #{n}"
    # end
    name "Random Number Company"
    description "Very mysterious"
  end
  
  factory :membership do
    organisation
    user
    admin false
    # factory :admin_membership do
    #   admin true
    # end
    
  end

end