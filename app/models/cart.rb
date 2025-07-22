class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy
end

public
def add_item(product)
  existing_item = cart_items.find_by(product_id: product.id)

  if existing_item
    false
  else
    cart_items.create(product: product)
    true
  end
end
