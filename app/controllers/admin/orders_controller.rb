class Admin::OrdersController < ApplicationController
  before_action :set_order, only: [ :show, :edit, :update, :destroy ]

  def index
    authorize [ :admin, Order ]
    @orders = policy_scope([ :admin, Order ])
  end

  def new
    @order = Order.new
    @order.order_items.build
  end

  def edit
  end

  def create
    @order = Order.new(order_params)
    total = 0
    @order.order_items.each do |item|
      product = Product.find(item.product_id)
      item.price_at_purchase = product.price if product
      total += item.price_at_purchase
    end

    @order.total_amount = total

    if @order.save
      redirect_to admin_order_path(@order), notice: "Order was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @order.update(order_params)
      redirect_to admin_order_path(@order), notice: "Order was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @order.destroy
    redirect_to admin_orders_path, notice: "Order was successfully deleted."
  end

  private

  def order_params
    params.require(:order).permit(
      :user_id, :status,
      order_items_attributes: [ :id, :product_id, :quantity, :price, :_destroy ]
    )
  end

  def set_order
    @order = Order.includes(:order_items, :user).find(params[:id])
  end
end
