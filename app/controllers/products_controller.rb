class ProductsController < ApplicationController
  # before_action :set_product, only: %i[ show ]
  # GET /products or /products.json
  def index
    @q = policy_scope(Product)
    .includes(:thumbnail_attachment, :category, :asset_attachment, :reviews)
    .where(status: "published")
    .ransack(params[:q])
    @products = @q.result
    .page(params[:page])
    .per(params[:per_page] || 6)
    # .yield_self { |scope|
    #   if params[:query].present?
    #     scope.where("name ILIKE ?", "%#{params[:query]}%")
    #   else
    #     scope
    #   end
    # }
    # .order(order_params)
  end

  # GET /products/1 or /products/1.json
  def show
    @product = Product.find(params[:id])
    @review = if user_signed_in?
      @product.reviews.find_or_initialize_by(user: current_user)
    end
    authorize @product
  end

  def download
    product = Product.find(params[:id])
    authorize product
    unless product.purchased_by?(current_user)
      redirect_to product_path(product), alert: "You must purchase this product to download it."
      nil
    end

    resolution = params[:resolution]
    video =
      case resolution
      when "full_hd"
        product.video_full_hd
      when "4k"
        product.video_4k
      when "hd"
        product.video_hd
      else
        product.asset
      end

    if video.attached?
      expires_now
      response.headers["Cache-Control"] = "no-store"
      # redirect_to rails_blob_url(video, disposition: "attachment")
      # send_data product.asset.download, filename: product.asset.filename.to_s, type: product.asset.content_type, disposition: "attachment"
      send_data video.download, filename: video.filename.to_s, type: video.content_type, disposition: "attachment"
    else
      redirect_to product_path(product), alert: "Requested video is not available."
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  # def set_product
  #   @product = Product.find(params[:id])
  # end
  def order_params
    allowed = %w[name created_at price]
    sort = params[:sort].presence_in(allowed) || "created_at"
    direction = params[:direction] == "asc" ? "asc" : "desc"
    "#{sort} #{direction}"
  end
end
