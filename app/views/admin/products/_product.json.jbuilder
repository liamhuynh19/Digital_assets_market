json.extract! product, :id, :user_id, :name, :description, :price, :file_url, :average_rating, :category_id, :created_at, :updated_at
json.url product_url(product, format: :json)
