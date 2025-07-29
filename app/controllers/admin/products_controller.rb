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
    update_params =
      if params[:product][:asset].present?
        product_params.merge(status: "processing")
      else
        product_params
      end

    @product = Product.new(product_params)
    @product.user = current_user
    authorize [ :admin, @product ]
    @product.assign_attributes(update_params)

    if @product.save
      if params[:product][:asset].present?
        case params[:product][:asset].content_type
        when "image/jpeg", "image/png", "image/gif"
          @product.process_image_thumbnail
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

    if @product.status == "processing" && params[:product][:asset].present?
      return  redirect_to edit_admin_product_path(@product), alert: "Cannot update product while it is processing a file upload."
    end

    update_params =
    if params[:product][:asset].present?
      product_params.merge(status: "processing")
    else
      product_params
    end

    if @product.update(update_params)
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

  def publish
    @product = Product.find(params[:id])
    authorize [ :admin, @product ]

    if @product.status == "uploaded" && @product.update(status: "published")
      redirect_back fallback_location: admin_products_path, notice: "Product was successfully published."
    else
      redirect_back fallback_location: admin_products_path, alert: "Failed to publish product. Only products with status 'uploaded' can be published."
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
    params.expect(product: [ :name, :description, :price, :category_id, :status, :asset ])
  end
end
