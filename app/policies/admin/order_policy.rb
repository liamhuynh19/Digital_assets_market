module Admin
  class OrderPolicy < ApplicationPolicy
    class Scope < ApplicationPolicy::Scope
      def resolve
        if user.role == "admin"
          scope.all
        elsif user.role == "seller"
          scope.joins(:order_items)
               .joins("JOIN products ON order_items.product_id = products.id")
               .where(products: { user_id: user.id })
               .distinct
        else
          scope.none
        end
      end
    end

    def index?
      user.present? && (user.role == "admin" || user.role == "seller")
    end

    def show?
      return false unless user.present?
      return true if user.role == "admin"

      if user.role == "seller"
        record.order_items.joins(:product).exists?(products: { user_id: user.id })
      else
        false
      end
    end

    def create?
      user.present? && user.role == "admin"
    end

    def new?
      create?
    end

    def update?
      user.present? && user.role == "admin"
    end

    def edit?
      update?
    end

    def destroy?
      user.present? && user.role == "admin"
    end
  end
end
