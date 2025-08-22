class MigrateUserRoles < ActiveRecord::Migration[8.0]
  def up
    # Create default roles
    %w[admin buyer seller].each do |role_name|
      Role.find_or_create_by(name: role_name)
    end

    # Migrate existing users
    User.find_each do |user|
      user.migrate_legacy_role
    end

    # Create basic permissions
    {
      "product" => [ "index", "show", "create", "update", "destroy" ],
      "user" => [ "index", "show", "create", "update", "destroy" ],
      "order" => [ "index", "show", "create", "update", "destroy" ],
      "report" => [ "show" ],
      "seller_application" => [ "index", "show", "approve", "reject" ]
    }.each do |resource, actions|
      actions.each do |action|
        Permission.find_or_create_by(
          name: "#{resource}:#{action}",
          resource: resource,
          action: action
        )
      end
    end

    # Assign permissions to roles
    admin_role = Role.find_by(name: "admin")
    seller_role = Role.find_by(name: "seller")
    buyer_role = Role.find_by(name: "buyer")

    # Admin has all permissions
    Permission.find_each do |permission|
      RolePermission.find_or_create_by(role: admin_role, permission: permission)
    end

    # Seller permissions
    %w[product:index product:show product:create product:update order:index order:show report:show].each do |perm|
      permission = Permission.find_by(name: perm)
      RolePermission.find_or_create_by(role: seller_role, permission: permission) if permission
    end

    # Buyer permissions
    %w[product:index product:show].each do |perm|
      permission = Permission.find_by(name: perm)
      RolePermission.find_or_create_by(role: buyer_role, permission: permission) if permission
    end
  end

  def down
    # This migration is not reversible
  end
end
