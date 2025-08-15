class Admin::SellerApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_application, only: [ :show, :approve, :reject ]

  def index
    @applications = SellerApplication.includes(:user, :reviewed_by).order(created_at: :desc)
    @applications = @applications.where(status: params[:status]) if params[:status].present?
  end

  def show
  end

  def approve
    @application.approve!(current_user)
    redirect_to admin_seller_applications_path, notice: "The seller application has been approved. The user is now a seller."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to admin_seller_application_path(@application), alert: e.record.errors.full_messages.to_sentence
  end

  def reject
    @application.reject!(current_user, rejection_reason: params[:seller_application][:rejection_reason])
    redirect_to admin_seller_applications_path, notice: "The seller application has been rejected."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to admin_seller_application_path(@application), alert: e.record.errors.full_messages.to_sentence
  end

  private

  def set_application
    @application = SellerApplication.find(params[:id])
  end

  def require_admin
    redirect_to root_path, alert: "You are not authorized to access this page." unless current_user.admin?
  end
end
