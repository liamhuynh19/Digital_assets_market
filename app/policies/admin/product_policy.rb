module Admin
  class ProductPolicy < ApplicationPolicy
    # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
    # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
    # In most cases the behavior will be identical, but if updating existing
    # code, beware of possible changes to the ancestors:
    # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

    class Scope < ApplicationPolicy::Scope
      # NOTE: Be explicit about which records you allow access to!
      def resolve
        if user.role == "admin"
          scope.all
        elsif user.role == "seller"
          scope.where(user_id: user.id)
        else
          scope.none
        end
      end
    end

    def index?
      user.present? && (user.role == "admin" || user.role == "seller")
    end

    def show?
      user.present? && (user.role == "admin" || (user.role == "seller" && record.user_id == user.id))
    end

    def create?
      user.present? && (user.role == "admin" || user.role == "seller")
    end

    def new?
      create?
    end

    def update?
      user.present? && (user.role == "admin" || (user.role == "seller" && record.user_id == user.id))
    end

    def publish?
      record.allow_to_publish? &&  (user.role == "admin" || (user.role == "seller" && record.user_id == user.id))
    end

    def destroy?
      user.present? && (user.role == "admin" || (user.role == "seller" && record.user_id == user.id))
    end
  end
end
