FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "#{Faker::Commerce.product_name} #{n}" }
    description { Faker::Lorem.paragraph }
    price { Faker::Commerce.price }
    association :user
    association :category
  end
end
