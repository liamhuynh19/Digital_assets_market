class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show ]
  before_action :authenticate_user!
  # GET /products or /products.json
  def index
    @products = policy_scope(Product).order(created_at: :desc).page(params[:page]).per(8)
  end

  # GET /products/1 or /products/1.json
  def show
    @product = Product.find(params.expect(:id))
    authorize @product
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find(params.expect(:id))
  end
end
