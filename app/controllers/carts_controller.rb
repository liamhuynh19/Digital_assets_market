class CartsController < ApplicationController
  before_action :authenticate_user!
  # before_action :set_cart, only: [ :show, :add_item, :remove_item ]
  def show
    @cart = current_user.cart
    @cart_items = @cart.cart_items.includes(:product)
  end

  def add_item
    FirstWorkerJob.perform_later("Adding item to cart")
    @cart = current_user.cart
    product = Product.find(params[:product_id])

    unless product
      flash[:alert] = "Product not found."
      redirect_back(fallback_location: root_path)
      return
    end


    if @cart.add_item(product)
      flash[:notice] = "Product added to cart."
      redirect_to cart_path
    else
      flash[:alert] = "Product is already in the cart."
      redirect_to cart_path
    end
  end

  def remove_item
    @cart = current_user.cart
    puts @cart.cart_items.inspect

    cart_item = @cart.cart_items.find(params[:id])

    if cart_item.destroy
      flash[:notice] = "Product removed from cart successfully."
      redirect_to cart_path
    else
      flash[:alert] = "Failed to remove product from cart."
      redirect_to cart_path
    end
  end

  private
end
