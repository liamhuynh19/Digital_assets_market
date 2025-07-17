FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "#{Faker::Name.name}_#{n}" }
    sequence(:email) { |n| "user_#{n}@#{Faker::Internet.domain_name}" }
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
