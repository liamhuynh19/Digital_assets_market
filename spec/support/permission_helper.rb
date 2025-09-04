module PermissionHelper
  ROLE_PERMISSIONS = {
    "admin" => {
      "product" => [ "index", "show", "create", "update", "publish", "destroy" ],
      "user" => [ "index", "show", "create", "update", "destroy" ],
      "category" => [ "index", "show", "create", "update", "destroy" ],
      "order" => [ "index", "show", "update", "destroy" ],
      "report" => [ "show" ],
      "seller_application" => [ "index", "show", "approve", "reject" ]
    },
    "seller" => {
      "product" => [ "index", "show", "create", "update", "publish", "destroy" ],
      "order" => [ "index", "show" ],
      "report" => [ "show" ],
      "category" => [ "index", "show" ]
    },
    "buyer" => {
      "product" => [ "index", "show", "purchased" ],
      "order" => [ "create", "show", "index" ],
      "cart" => [ "show", "add_item", "remove_item" ]
    }
  }


  def self.setup_default_permissions
    ROLE_PERMISSIONS.values.each do |resources|
      resources.each do |resource, actions|
        actions.each do |action|
          Permission.find_or_create_by(
            name: "#{resource}_#{action}",
            resource: resource,
            action: action
          )
        end
      end
    end

    ROLE_PERMISSIONS.each do |role_name, resources|
      role = Role.find_or_create_by(name: role_name)
      resources.each do |resource, actions |
        actions.each do |action|
          permission = Permission.find_by(resource: resource, action: action)
          role.permissions << permission if permission && !role.permissions.include?(permission)
        end
      end
    end
  end
end
