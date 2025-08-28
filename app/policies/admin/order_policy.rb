module Admin
  class OrderPolicy < ApplicationPolicy
    class Scope < ApplicationPolicy::Scope
      def resolve
        if user.has_role?("admin")
          scope.includes([ :user, :order_items ]).all
        elsif user.has_role?("seller")
          scope.joins(:order_items)
                .includes([ :user, :order_items ])
               .joins("JOIN products ON order_items.product_id = products.id")
               .where(products: { user_id: user.id })
               .distinct
        else
          scope.none
        end
      end
    end

    def index?
      user.present? && (user.has_role?("admin") || user.has_role?("seller"))
    end

    def show?
      return false unless user.present?
      return true if user.has_role?("admin")

      if user.has_role?("seller")
        record.order_items.joins(:product).exists?(products: { user_id: user.id })
      else
        false
      end
    end

    def create?
      user.present? && user.has_role?("admin")
    end

    def new?
      create?
    end

    def update?
      user.present? && user.has_role?("admin")
    end

    def edit?
      update?
    end

    def destroy?
      user.present? && user.has_role?("admin")
    end
  end
end
