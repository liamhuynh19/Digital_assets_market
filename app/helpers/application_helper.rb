module ApplicationHelper
  def pending_seller_applications_count
    @pending_seller_applications_count ||= SellerApplication.pending.count
  end
end
