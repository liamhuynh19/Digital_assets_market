FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 6) }
    role { "buyer" }

    trait :admin do
      role { "admin" }
    end

    trait :seller do
      role { "seller" }
    end
  end
end
