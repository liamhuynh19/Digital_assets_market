class Api::V1::OrdersController < Api::V1::BaseController
  # before_action :authenticate_user!
  # skip_before_action :verify_authenticity_token, only: [ :create ]
  def create
    product_ids = JSON.parse(params[:product_ids])

    order = Order.new(user: current_user)
    if product_ids && product_ids != []
      products = Product.where(id: product_ids)
      order_items = OrderItem.where(product_id: product_ids)

      if products.length != product_ids.length || order_items.length > 0
        return render json: { error: "Product_ids invalid (Contain invalid id or already ordered by current user)" }, status: :unprocessable_entity
      end
      order.total_amount = products.sum(:price)
      if order.save
        products.each do |product|
          order.order_items.create!(product: product, price_at_purchase: product.price)
        end
        render json: { message: "Order created successfully", order_id: order.id }, status: :created
      else
        render json: { error: "Failed to create order" }, status: :unprocessable_entity
      end
    else
      render json: { error: "No products selected" }, status: :unprocessable_entity
    end
  end

  def show
    @order = Order.find(params[:id])
  end

  def index
    @orders = Order.includes(:user, order_items: [ product: :category ])
    .where(user: current_user)
    .all()
  end

  def mark_as_paid
    @order = Order.find(params[:id])


    if @order && @order.status != "paid" && @order.user == current_user
      @order.update(status: "paid")
      render json: { data:  { message: "Order marked as paid" }, status: :ok }
    else
      render json: { data:  { error: "Unauthorized action or order has been paid" } }
    end
  rescue ActiveRecord::RecordNotFound
    render json: { data: { error: "Order not found" }, status: :not_found }
  end
end
