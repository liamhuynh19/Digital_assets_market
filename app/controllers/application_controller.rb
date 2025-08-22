class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  # , :rack_mini_profiler_authorize_request?
  include Pundit::Authorization
  before_action :configure_permitted_parameters, if: :devise_controller?  # Add this line

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  layout :set_layout
  before_action :set_cart
  before_action :set_search

  private

  def after_sign_in_path_for(resource)
    case resource.role
    when "admin", "seller"
      admin_products_path
    when "buyer"
      products_path
    else
      super
    end
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referer || root_path)
  end

  def set_layout
    if current_user
      case current_user.role
      when "buyer"
        "buyer"
      when "seller", "admin"
        "admin"
      else
        "application"
      end
    else
      "application"
    end
  end

  def set_cart
    return unless current_user
    @cart = current_user.cart || current_user.create_cart
    @cart_items = @cart.cart_items.includes(product: [ :thumbnail_attachment  ]) if @cart
  end

  def set_search
    @q = Product.ransack(params[:q])
  end

  # def rack_mini_profiler_authorize_request?
  #   Rack::MiniProfiler.authorize_request
  # end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :email, :password, :password_confirmation, :phone_number ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :email, :password, :password_confirmation, :phone_number ])
  end
end
