class Admin::ReviewPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.seller?
        scope.where(product: Product.where(user_id: user.id))
      else
        scope.none
      end
    end
  end

  def index?
    user.admin? || user.seller?
  end

  def show?
    user.admin? || (user.seller? && record.product.user_id == user.id)
  end


  def destroy?
    user.admin?
  end
end
