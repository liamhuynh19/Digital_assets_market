# class CartsController < ApplicationController
#   before_action :authenticate_user!
#   before_action :set_cart, only: [ :show, :add_item, :remove_item ]
#   def show
#     @cart = current_user.cart
#     @cart_items = @cart.cart_items.includes(:product)
#   end

#   def add_item
#     @cart = current_user.cart
#     product = Product.find(params[:product_id])
#     @cart.add_product(product)

#     if @cart.save
#       flash[:notice] = "Product added to cart successfully."
#       redirect_to cart_path
#     else
#       flash[:alert] = "Failed to add product to cart."
#       redirect_back(fallback_location: root_path)
#     end
#   end

#   def remove_item
#     @cart = current_user.cart
#     cart_item = @cart.cart_items.find(params[:id])
#     cart_item.destroy

#     flash[:notice] = "Product removed from cart successfully."
#     redirect_to cart_path
#   end
#   private

#   def set_cart
#     @cart = current_user.cart || current_user.create_cart
#   end
# end
