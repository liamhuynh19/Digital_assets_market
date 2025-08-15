class Users::SellerApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_if_buyer, only: [ :new, :create ]

  def show
    @seller_application = current_user.seller_applications.order(created_at: :desc).first
    redirect_to new_users_seller_application_path, alert: "You don't have any seller applications yet." unless @seller_application
  end

  def new
    @seller_application = current_user.seller_applications.build
  end

  def create
    @seller_application = current_user.seller_applications.build(seller_application_params)

    if @seller_application.save
      redirect_to users_seller_application_path, notice: "Your seller application has been submitted."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def seller_application_params
    params.require(:seller_application).permit(:reason)
  end

  def check_if_buyer
    redirect_to root_path, alert: "Only buyers can apply to become sellers." unless current_user.buyer?
  end
end
