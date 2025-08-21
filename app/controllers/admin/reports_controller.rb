class Admin::ReportsController < ApplicationController
  before_action :authenticate_user!

  def show
    authorize :report
    @period = params[:period] || "all_time"

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
    date_range = get_date_range(@period)

    @total_users = User.where(date_range.present? ? { created_at: date_range } : {}).count
    @product = Product.where(date_range.present? ? { created_at: date_range } : {}).all
    @total_products = @product.count
    @published_products = @product.where(status: "published").count

    seller_applications = SellerApplication.where(date_range.present? ? { created_at: date_range } : {}).all()
    @total_seller_applications = seller_applications.count
    @approved_seller_applications = seller_applications.where(status: "approved").count
    @rejected_seller_applications = seller_applications.where(status: "rejected").count
    @pending_seller_applications = seller_applications.where(status: "pending").count

    @orders = Order.order(created_at: :desc)
    @orders = @orders.where(created_at: date_range) if date_range.present?

    @total_orders = @orders.count
    @paid_orders = @orders.where(status: "paid")
    @paid_orders_count = @paid_orders.count
    @total_orders = @orders.count
    @revenue = @paid_orders.sum(:total_amount)
    if date_range.present?
      @total_reviews = Review.where(created_at: date_range).count
    else
      @total_reviews = Review.count
    end

    @top_products = Product
      .joins(order_items: :order)
      .where(orders: { status: "paid" })
      .where(date_range.present? ? { orders: { created_at: date_range } } : {})
      .select("products.*, COUNT(order_items.id) AS units_sold")
      .group("products.id")
      .order("units_sold DESC")
      .includes(:category, :thumbnail_attachment)
      .limit(3)

    @top_sellers = User.joins(products: [ order_items: :order ])
                      .where(orders: { status: "paid" })
                      .where(date_range.present? ? { orders: { created_at: date_range } } : {})
                      .select("users.*, COUNT(order_items.id) AS items_sold")
                      .group("users.id")
                      .order("items_sold DESC")
                      .limit(3)
  end

  def build_seller_report
    date_range = get_date_range(@period)

    @products = current_user.products.where(date_range.present? ? { created_at: date_range } : {})
    @product_ids = @products.select(:id)


    @paid_items_query = OrderItem.joins(:order).where(product_id: @product_ids, orders: { status: "paid" })
    @paid_items_query = @paid_items_query.where(orders: { created_at: date_range }) if date_range.present?
    @paid_items = @paid_items_query

    @paid_orders_count = @paid_items.distinct.count("orders.id")
    @total_products = @products.count
    @published_products = @products.where(status: "published").count

    reviews_query = Review.where(product_id: @product_ids)
    reviews_query = reviews_query.where(created_at: date_range) if date_range.present?
    @total_reviews = reviews_query.count
    @average_rating = reviews_query.average(:rating) || 0

    orders_query = OrderItem.joins(:order).where(product_id: @product_ids)
    orders_query = orders_query.where(orders: { created_at: date_range }) if date_range.present?
    @total_orders = orders_query.distinct.count("orders.id")


    @top_products = @products
                     .joins(order_items: :order)
                     .where(orders: { status: "paid" })
                     .where(date_range.present? ? { orders: { created_at: date_range } } : {})
                     .includes(:category, :thumbnail_attachment)
                     .select("products.*, COUNT(order_items.id) AS items_sold")
                     .group("products.id")
                     .order("items_sold DESC")
                     .limit(3)

    @revenue = @paid_items.sum("order_items.price_at_purchase")
  end

  def get_date_range(period)
    case period
    when "today"
      Date.today.beginning_of_day..Date.today.end_of_day
    when "yesterday"
      Date.yesterday.beginning_of_day..Date.yesterday.end_of_day
    when "this_week"
      Date.today.beginning_of_week..Date.today.end_of_week
    when "last_week"
      1.week.ago.beginning_of_week..1.week.ago.end_of_week
    when "this_month"
      Date.today.beginning_of_month..Date.today.end_of_month
    when "last_month"
      1.month.ago.beginning_of_month..1.month.ago.end_of_month
    when "last_30_days"
      30.days.ago.beginning_of_day..Date.today.end_of_day
    when "last_90_days"
      90.days.ago.beginning_of_day..Date.today.end_of_day
    when "this_year"
      Date.today.beginning_of_year..Date.today.end_of_year
    when "last_year"
      1.year.ago.beginning_of_year..1.year.ago.end_of_year
    when "all_time"
      nil
    else
      nil
    end
  end

  def period_name(period)
    {
      "today" => "Today",
      "yesterday" => "Yesterday",
      "this_week" => "This Week",
      "last_week" => "Last Week",
      "this_month" => "This Month",
      "last_month" => "Last Month",
      "last_30_days" => "Last 30 Days",
      "last_90_days" => "Last 90 Days",
      "this_year" => "This Year",
      "last_year" => "Last Year",
      "all_time" => "All Time"
    }[period]
  end
  helper_method :period_name
end
