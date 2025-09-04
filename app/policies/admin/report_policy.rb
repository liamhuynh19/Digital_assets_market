class Admin::ReportPolicy < ApplicationPolicy
  def show?
    user_has_permission?("report", "show") && user.admin? || user.seller?
  end
end
