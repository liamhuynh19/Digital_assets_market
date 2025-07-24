class ProductsController < ApplicationController
  # before_action :set_product, only: %i[ show ]
  # GET /products or /products.json
  def index
    @products = policy_scope(Product).where(status: "published").order(created_at: :desc).page(params[:page]).per(6)
  end

  # GET /products/1 or /products/1.json
  def show
    @product = Product.find(params[:id])
    authorize @product
  end

  def download
    product = Product.find(params[:id])
    authorize product
    unless product.purchased_by?(current_user)
      redirect_to product_path(product), alert: "You must purchase this product to download it."
      nil
    end
    if product.asset.attached?
      # redirect_to rails_blob_url(product.asset, disposition: "attachment")
      send_data product.asset.download, filename: product.asset.filename.to_s, type: product.asset.content_type, disposition: "attachment"
    else
      redirect_to product_path(product), alert: "No asset available for download."
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  # def set_product
  #   @product = Product.find(params[:id])
  # end
end
