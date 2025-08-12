class Admin::ReportsPolicy < ApplicationPolicy
  def show?
    user.admin? || user.seller?
  end
end
