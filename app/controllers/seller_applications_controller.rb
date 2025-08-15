class SellerApplicationsController < ApplicationController
  before_action :authenticate_user!

  def new
    return redirect_to root_path, alert: "You are already a seller or have a pending application." unless current_user.can_apply_for_seller?
    @seller_application = current_user.seller_applications.build
  end

  def create
    return redirect_to root_path, alert: "You are already a seller or have a pending application." unless current_user.can_apply_for_seller?
    @seller_application = current_user.seller_applications.build(seller_application_params)
    if @seller_application.save
      redirect_to root_path, notice: "Your seller application has been submitted successfully. We will review it shortly."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def seller_application_params
    params.require(:seller_application).permit(:reason)
  end
end
