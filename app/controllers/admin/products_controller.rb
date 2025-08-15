require "csv"
require "set"
class Admin::ProductsController < ApplicationController
  before_action :set_product, only: [ :show, :edit, :update, :destroy ]

  def index
    authorize [ :admin, Product ]
    @products = policy_scope([ :admin, Product ])
                 .includes(:category, :thumbnail_attachment)
                 .order(created_at: :desc)
                 .page(params[:page]).per(params[:per_page] || 10)

    cache_key = "bulk_import_products:result:user:#{current_user.id}"
    res = Rails.cache.read(cache_key)

    if res
      if res[:aborted]
        flash.now[:alert] = build_import_error_message(res)
      else
        flash.now[:notice] = "Bulk import completed: #{res[:imported]} products created."
      end
      Rails.cache.delete(cache_key)
    end
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

  def bulk_import
    unless params[:csv].present?
      flash[:alert] = "Please upload a CSV file."
      return redirect_to admin_products_path
    end

    file_data = params[:csv].read

    ImportProductJob.perform_later(current_user.id, file_data)

    flash[:notice] = "Import job has been queued. You will be notified when it completes."
    redirect_to admin_products_path
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.expect(product: [ :name, :description, :price, :category_id, :status, :asset ])
  end

  def build_import_error_message(res)
    base = "Bulk import failed. No products created."
    details = res[:errors].first(5).map { |e|
      line = e[:line] ? "Line #{e[:line]}: " : ""
      "#{line}#{e[:errors].join(', ')}"
    }.join(" | ")
    if res[:errors].size > 5
      "#{base} #{details} ... (+#{res[:errors].size - 5} more)"
    else
      "#{base} #{details}"
    end
  end
end
