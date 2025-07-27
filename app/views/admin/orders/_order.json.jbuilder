json.extract! order, :id, :user_id, :total_amount, :status, :created_at, :updated_at
json.items order.order_items do |item|
  json.extract! item, :id, :product_id, :quantity, :price
  json.product_name item.product.name
end