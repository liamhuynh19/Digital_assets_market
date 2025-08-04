json.data do
  json.order do
    json.extract! @order, :id, :total_amount, :created_at, :updated_at
    json.user do
      json.extract! @order.user, :id, :email, :name
    end

    json.order_items @order.order_items do |item|
      json.extract! item, :id, :price_at_purchase, :created_at

      json.product do
        json.extract! item.product, :id, :name, :description, :price, :status, :created_at, :updated_at
        json.category do
          if item.product.category.present?
            json.extract! item.product.category, :id, :name
          else
            json.null!
          end
        end
      end
    end
  end
end
