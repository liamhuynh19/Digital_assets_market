FactoryBot.define do
  factory :category do
    name { Faker::Commerce.department(max: 1) }
    description { Faker::Lorem.sentence }
  end
end
