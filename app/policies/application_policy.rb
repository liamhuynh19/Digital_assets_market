class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
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
