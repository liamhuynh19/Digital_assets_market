class AdminPolicy < ApplicationPolicy
  def index?
    user.present? && user.admin?
  end
end
