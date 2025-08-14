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
    @product = Product.all
    @total_products = @product.count
    @published_products = @product.where(status: "published").count

    @orders = Order.order(created_at: :desc)
    @total_orders = @orders.count
    @paid_orders = @orders.where(status: "paid")
    @paid_orders_count = @paid_orders.count
    @total_orders = @orders.count
    @revenue = @paid_orders.sum(:total_amount)
    @total_reviews = Review.count

    @top_products = Product
      .joins(order_items: :order)
      .where(orders: { status: "paid" })
      .select("products.*, COUNT(order_items.id) AS units_sold")
      .group("products.id")
      .order("units_sold DESC")
      .includes(:category, :thumbnail_attachment)
      .limit(3)
    @top_sellers = User.joins(products: [ order_items: :order ])
                      .where(orders: { status: "paid" })
                       .select("users.*, COUNT(order_items.id) AS items_sold")
                       .group("users.id")
                       .order("items_sold DESC")
                       .limit(3)
  end

  def build_seller_report
    @products = current_user.products
    @product_ids = @products.select(:id)
    @paid_items = OrderItem.joins(:order).where(product_id: @product_ids, orders: { status: "paid" })
    @paid_orders_count = @paid_items.distinct.count("orders.id")

    @total_products = @products.count
    @published_products = @products.where(status: "published").count
    @total_reviews = Review.where(product_id: @product_ids).count
    @average_rating = Review.where(product_id: @product_ids).average(:rating) || 0
    @total_orders = OrderItem.joins(:order).where(product_id: @product_ids).distinct.count("orders.id")
    @top_products = @products
                     .joins(order_items: :order)
                     .where(orders: { status: "paid" })
                     .includes(:category, :thumbnail_attachment)
                     .select("products.*, COUNT(order_items.id) AS items_sold")
                     .group("products.id")
                     .order("items_sold DESC")
                     .limit(3)
    @revenue = @paid_items.sum("order_items.price_at_purchase")
  end
end
