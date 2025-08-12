class Admin::ReportsController < ApplicationController
  before_action :authenticate_user!

  def show
    authorize :report
    if current_user.admin?
      build_admin_report
    elsif current_user.seller?
      build_seller_report
    else
      redirect_to root_path, alert: "You do not have permission to view this report."
    end
  end

  private
  def build_admin_report
    @total_users = User.count
    @total_products = Product.count
    @total_orders = Order.count
    @orders = Order.order(created_at: :desc)
    @paid_orders = @orders.where(status: "paid")
    @total_orders = @orders.count
    @total_reviews = Review.count
    @revenue = @paid_orders.sum(:total_amount)
    @top_products = Product.joins(:order_items)
                           .group("products.id")
                           .order("COUNT(order_items) DESC")
                           .limit(3)
    @top_sellers = User.joins(products: :order_items)
                       .select("users.*, COUNT(order_items.id) AS items_sold")
                       .group("users.id")
                       .order("items_sold DESC")
                       .limit(3)
  end

  def build_seller_report
    @products = current_user.products
    @product_ids = @products.select(:id)
    @paid_items = OrderItem.joins(:order).where(product_id: @product_ids, orders: { status: "paid" })


    @total_products = @products.count
    @total_reviews = Review.where(product_id: @product_ids).count
    @average_rating = Review.where(product_id: @product_ids).average(:rating) || 0
    @total_orders = OrderItem.joins(:order).where(product_id: @product_ids, orders: { status: "paid" }).distinct.count("orders.id")
    @top_products = @products
                     .joins(:order_items)
                     .select("products.*, COUNT(order_items.id) AS items_sold")
                     .group("products.id")
                     .order("items_sold DESC")
    @total_revenue = @paid_items.sum("order_items.price_at_purchase")
  end
end
