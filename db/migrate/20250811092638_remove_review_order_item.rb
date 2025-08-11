class RemoveReviewOrderItem < ActiveRecord::Migration[8.0]
  def up
    remove_column :reviews, :order_item_id, :bigint
    add_index :reviews, [ :user_id, :product_id ], unique: true, name: "index_reviews_on_user_and_product"
  end

  def down
    add_column :reviews, :order_item_id, :bigint
    remove_index :reviews, name: "index_reviews_on_user_and_product"
  end
end
