class OrdersController < ApplicationController
  before_action :set_order, only: [ :show, :edit, :update, :destroy ]

  def index
    @orders = Order.all.where(user: current_user)
  end

  def show
  end

  def new
    @order = Order.new
  end

  def edit
  end

  def create
    product_ids = params[:order][:product_ids] || []
    total_amount = params[:order][:total_amount] || 0

    @order = Order.new(user: current_user, total_amount: total_amount)
    @cart = current_user.cart

    if @order.save
      products = Product.where(id: product_ids)
      products.each do |product|
        @order.order_items.create!(product_id: product.id, price_at_purchase: product.price)
        @cart.cart_items.find_by(product_id: product.id).destroy!
      end

      redirect_to @order, notice: "Order was successfully created."
    else
      raise ActiveRecord::Rollback
      redirect_to cart_path, alert: "Failed to create order. Please try again."
    end
  end

  def update
    if @order.update(order_params)
      redirect_to @order, notice: "Order was successfully updated."
    else
      render :edit
    end
  end

  def mark_as_paid
    @order = Order.find(params[:order_id])
    @order.update(status: "paid")

    redirect_to @order, notice: "Your order has been paid successfully."

  rescue ActiveRecord::RecordNotFound
    redirect_to orders_path, alert: "Order not found."
  end

  def destroy
    @order.destroy
    redirect_to orders_url, notice: "Order was successfully destroyed."
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.expect(order: [ :total_amount, :status ])
  end
end
