json.data do
  json.array! @orders do |order|
    json.id order.id
    json.total_amount order.total_amount
    json.created_at order.created_at.iso8601
    json.updated_at order.updated_at.iso8601

    json.user do
      json.id order.user.id
      json.email order.user.email
      json.name order.user.name
    end

    json.order_items order.order_items do |item|
      json.id item.id
      json.price_at_purchase item.price_at_purchase
      json.created_at item.created_at.iso8601

      json.product do
        json.extract! item.product, :id, :name, :description, :price, :status, :created_at, :updated_at
        if item.product.category.present?
          json.category do
            json.extract! item.product.category, :id, :name
          end
        else
          json.null!
        end
      end
    end
  end
end
