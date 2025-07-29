class Api::ProductsController < ApplicationController
  def index
    @products = Product
    .includes([ :asset_attachment, :thumbnail_attachment, :video_hd_attachment,
    :video_4k_attachment, :video_full_hd_attachment, :user,  :category ])
    .where(status: "published")
    .order(created_at: :desc)
    .page(params[:page])
    .per(params[:per_page] || 6)
    authorize @products
  end
end
