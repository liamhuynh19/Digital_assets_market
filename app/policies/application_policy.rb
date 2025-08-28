class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  # Check if user has any permission for the given resource and action
  def user_has_permission?(resource, action)
    return false unless user

    # Direct role check for backward compatibility
    return true if user.admin?

    # Check permissions through roles
    user.roles.joins(:permissions)
        .exists?(permissions: { resource: resource.to_s, action: action.to_s })
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
      raise Pundit::NotAuthorizedError, "must be logged in" unless user
    end

    def resolve
      scope.all
    end
  end
end
