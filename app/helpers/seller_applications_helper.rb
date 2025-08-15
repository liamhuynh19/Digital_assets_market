module SellerApplicationsHelper
  def seller_application_status_badge(status)
    case status
    when "pending"
      content_tag(:span, "Pending", class: "badge badge-warning")
    when "approved"
      content_tag(:span, "Approved", class: "badge badge-success")
    when "rejected"
      content_tag(:span, "Rejected", class: "badge badge-danger")
    else
      content_tag(:span, status.capitalize, class: "badge badge-secondary")
    end
  end
end
