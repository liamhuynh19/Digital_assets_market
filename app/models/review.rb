class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, presence: true, length: { maximum: 2000 }
  validates :user_id, uniqueness: { scope: :product_id, message: "has already reviewed this product" }

  validate :user_must_have_purchased_product

  private

  def user_must_have_purchased_product
    return if user.blank? || product.blank?

    purchased_order_item = OrderItem
      .joins(:order)
      .where(product_id: product.id, orders: { user_id: user.id, status: %w[paid] })
      .order(created_at: :desc)
      .first
    if purchased_order_item.nil?
      errors.add(:base, "You can only review products you have purchased")
    end
  end
end
