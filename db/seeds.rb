# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#
# Create default users
users = [
  { email: "admin@gmail.com",  password: "admin123",  role: "admin" },
  { email: "buyer@gmail.com",  password: "buyer123",  role: "buyer" },
  { email: "seller@gmail.com", password: "seller123", role: "seller" }
]

users.each do |attrs|
  user = User.find_or_initialize_by(email: attrs[:email])
  user.password = attrs[:password]
  user.role = attrs[:role]
  user.save!
end


# require 'faker'

# categories = []
# 10.times do
#   categories << Category.create!(
#     name: Faker::Commerce.unique.department,
#     description: Faker::Lorem.paragraph
#   )
# end

# 300.times do
#   ActiveRecord::Base.transaction do
#     user = User.create!(
#       name: Faker::Name.name,
#       email: Faker::Internet.unique.email,
#       password: 'password',
#       role: 'seller'
#     )

#     products = []
#     10_000.times do
#       products << {
#         name: Faker::Commerce.product_name,
#         description: Faker::Lorem.sentence,
#         price: Faker::Commerce.price(range: 1.0..1000.0),
#         status: [ 'draft', 'published', 'uploaded' ].sample,
#         user_id: user.id,
#         category_id: categories.sample.id,
#         created_at: Time.now,
#         updated_at: Time.now
#       }
#     end
#     Product.insert_all(products)
#   end
# end
