class RootController < ApplicationController
  def index
    if user_signed_in?
      case current_user.current_view
      when "admin" || "seller"
        redirect_to admin_products_path
      else
        redirect_to products_path
      end
    else
      redirect_to login_path, notice: "Please log in to access the site."
    end
  end
end
