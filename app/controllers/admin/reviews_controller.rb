class Admin::ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [ :index ]
  before_action :set_review, only: [ :show, :destroy ]

  def index
    authorize [ :admin, Review ]

    scope = policy_scope([ :admin, Review ])
              .includes(:user, :product)
              .order(created_at: :desc)

    scope = scope.where(product_id: @product.id) if @product
    scope = scope.where(product_id: params[:product_id]) if params[:product_id].present?
    scope = scope.where(rating: params[:rating]) if params[:rating].present?
    q = ActiveRecord::Base.sanitize_sql_like(params[:q]) if params[:q].present?
    scope = scope.joins(:user).where("users.email ILIKE ?", "%#{q}%")

    @reviews = scope.page(params[:page]).per(params[:per_page] || 10)
  end

  def show
    authorize [ :admin, @review ]
  end

  # def edit
  #   authorize [ :admin, @review ]
  # end

  # def update
  #   authorize [ :admin, @review ]
  #   if @review.update(review_params)
  #     redirect_to admin_reviews_path(product_id: @review.product_id), notice: "Review updated."
  #   else
  #     render :edit, status: :unprocessable_entity
  #   end
  # end

  def destroy
    authorize [ :admin, @review ]
    @review.destroy
    redirect_to admin_reviews_path(product_id: @review.product_id), notice: "Review deleted."
  end

  private

  def set_product
    @product = Product.find_by(id: params[:product_id])
  end

  def set_review
    @review = Review.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
