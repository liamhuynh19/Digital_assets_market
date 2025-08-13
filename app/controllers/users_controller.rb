class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[  profile edit update  ]

  def profile
    @user = current_user
    @orders = @user.orders.includes(order_items: :product).order(created_at: :desc)
    @orders_count = @orders.count
    @paid_orders = @user.orders.where(status: "paid")
    @paid_orders_count = @paid_orders.count
    @total_spent = @paid_orders.sum(:total_amount)
    @purchased_products_count = @paid_orders.joins(:order_items).distinct.count("order_items.product_id")
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = current_user
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.expect(user: [ :name, :email, :role ])
  end
end
