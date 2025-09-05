module Admin
  class OrderPolicy < ApplicationPolicy
    class Scope < ApplicationPolicy::Scope
      def resolve
        if user.admin?
          scope.includes([ :user, :order_items ]).all
        elsif user.seller?
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
      user.present? && (user.admin? || user.seller?)
    end

    def show?
      user.present? && (user.admin? ||
      (user.seller? && record.order_items.joins(:product).exists?(products: { user_id: user.id })))
    end

    def create?
      user.present? && user.admin?
    end

    def new?
      create?
    end

    def update?
      user.present? && user.admin?
    end

    def edit?
      update?
    end

    def destroy?
      user.present? && user.admin?
    end
  end
end
