class Admin::ProductsController < ApplicationController
  before_action :set_product, only: [ :show, :edit, :update, :destroy ]

  def index
    authorize [ :admin, Product ]
    @products = policy_scope([ :admin, Product ])
  end

  def show
    @product = Product.find(params[:id])
    authorize [ :admin, @product ]
  end

  def new
    @product = Product.new
    authorize [ :admin, @product ]
  end

  def create
    @product = Product.new(product_params)
    @product.user = current_user
    authorize [ :admin, @product ]
    if @product.save
      if params[:product][:asset].present?
        case params[:product][:asset].content_type
        when "image/jpeg", "image/png", "image/gif"
          process_image_thumbnail
        else
          AssetUploadJob.perform_later(@product.id)
        end
      end
      redirect_to admin_product_path(@product), notice: "Product was successfully created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    authorize [ :admin, @product ]
    if @product.update(product_params)
      if params[:product][:asset].present?
        case params[:product][:asset].content_type
        when "image/jpeg", "image/png", "image/gif"
          @product.process_image_thumbnail
        else
          AssetUploadJob.perform_later(@product.id)
        end
      end
      redirect_to admin_product_path(@product), notice: "Product was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    authorize [ :admin, @product ]
    @product.destroy
    redirect_to admin_products_path, notice: "Product was successfully deleted."
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.expect(product: [ :name, :description, :price, :file_url, :category_id, :asset ])
  end
end
