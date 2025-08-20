class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product
  before_action :set_review, only: [ :edit, :update, :destroy ]
  before_action :authorize_owner!, only: [ :edit, :update, :destroy ]

  # GET /reviews or /reviews.json
  def index
    @reviews = Review.all
  end

  # GET /reviews/1 or /reviews/1.json
  def show
  end

  # GET /reviews/new
  def new
    @review = Review.new
  end

  # GET /reviews/1/edit
  def edit
    # Renders edit.html.erb into turbo frame
  end

  # POST /reviews or /reviews.json
  def create
    @review = @product.reviews.find_or_initialize_by(user: current_user)
    @review.assign_attributes(review_params)

    if @review.save
      update_product_average_rating
      redirect_to @product, notice: "Review saved."
    else
      redirect_to @product, alert: @review.errors.full_messages.to_sentence
    end
  end

  # PATCH/PUT /reviews/1 or /reviews/1.json
  def update
    if @review.update(review_params)
      update_product_average_rating
      redirect_to @product, notice: "Review updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /reviews/1 or /reviews/1.json
  def destroy
    @review.destroy
    update_product_average_rating
    redirect_to @product, notice: "Review deleted."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_review
    @review = @product.reviews.find(params[:id])
  end

  def authorize_owner!
    redirect_to @product, alert: "Not authorized" unless @review.user_id == current_user.id
  end

  # Only allow a list of trusted parameters through.
  def review_params
    params.require(:review).permit(:rating, :comment)
  end

  # Update product's average rating
  def update_product_average_rating
    ratings = @product.reviews.pluck(:rating).compact
    if ratings.any?
      average = ratings.sum.to_f / ratings.size
      @product.update(average_rating: average.round(1))
    else
      @product.update(average_rating: nil)
    end
  end
end
