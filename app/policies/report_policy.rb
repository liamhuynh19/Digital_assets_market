class ReportPolicy < ApplicationPolicy
  def show?
    user.admin? || user.seller?
  end
end
