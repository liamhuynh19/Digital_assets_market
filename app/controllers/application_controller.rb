class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  # , :rack_mini_profiler_authorize_request?
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  layout :set_layout
  before_action :set_cart
  before_action :set_search

  private

  def switch_role
    role_name = params[:role]
    if current_user&.has_role?(role_name)
      current_user.set_current_role(role_name)
      redirect_back(fallback_location: root_path, notice: "Switched to #{role_name} view")
    else
      redirect_back(fallback_location: root_path, alert: "You don't have the #{role_name} role")
    end
  end

  def after_sign_in_path_for(resource)
    # Set default current_role if not already set
    if resource.current_role.nil? && resource.roles.any?
      resource.update(current_role: resource.roles.first)
    end

    case resource.current_view
    when "admin"
      admin_products_path
    when "seller"
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
      case current_user.current_view
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
    @cart_items = @cart.cart_items.includes(product: [ :thumbnail_attachment ]) if @cart
  end

  def set_search
    @q = Product.ransack(params[:q])
  end

  # def rack_mini_profiler_authorize_request?
  #   Rack::MiniProfiler.authorize_request
  # end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :email, :password, :password_confirmation, :phone_number ])
  end
end
