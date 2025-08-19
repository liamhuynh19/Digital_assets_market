require "benchmark"
class Api::V1::ProductsController < Api::V1::BaseController
  # before_action :authenticate_user!, only: [ :index, :show ]
  def index
    # Benchmark.bm(10) do |x|
    #   x.report("Method A:") { 1_000_000.times { "a" + "b" } }
    #   x.report("Method B:") { 1_000_000.times { "ab" } }
    #   x.report("Method C:") { 1_000_000.times { "a".concat("b") } }
    # end
    time = Benchmark.measure do
      query =
      Product
      .includes([ :asset_attachment, :thumbnail_attachment, :video_hd_attachment,
      :video_4k_attachment, :video_full_hd_attachment, :user,  :category ])
      .where(status: "published")
      .yield_self { |scope|
        if params[:query].present?
          query = ActiveRecord::Base.sanitize_sql_like(params[:query])
          scope.where("name ILIKE ?", "%#{query}%")
        else
          scope
        end
      }
      .order(order_params)
      .page(params[:page])
      .per(params[:per_page] || 6)

      puts "Query: #{query.to_sql}"

      @products = query
      authorize @products
    end
    puts "Index action took #{time.real} seconds"
  end

  def show
    @product = Product.find(params[:id])
    authorize @product
  end

  private
  def order_params
    allowed = %w[name created_at price]
    sort = params[:sort].presence_in(allowed) || "created_at"
    direction = params[:direction] == "asc" ? "asc" : "desc"
    "#{sort} #{direction}"
  end
end
