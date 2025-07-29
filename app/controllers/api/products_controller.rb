class Api::ProductsController < ApplicationController
  def index
    @products = Product.where(status: "published").order(created_at: :desc).page(params[:page]).per(6)
    authorize @products
  end
end
