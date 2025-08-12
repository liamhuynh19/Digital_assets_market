class Admin::ReviewPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.all if user.admin?
      scope.none
    end
  end

  def index?
    true
  end

  def edit?
    true
  end

  def update?
    true
  end

  def destroy?
    true
  end
end
