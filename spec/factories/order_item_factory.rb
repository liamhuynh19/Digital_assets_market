FactoryBot.define do
  factory :order_item do
    association :order
    association :product
  end
end
