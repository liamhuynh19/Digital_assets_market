FactoryBot.define do
  factory :order do
    association :user
    total_amount { Faker::Commerce.price(range: 10.0 .. 100.0) }
    status { "pending" }
    trait :paid do
      status { "paid" }
    end
  end
end
