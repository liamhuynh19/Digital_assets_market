class CreateRolesAndPermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.string :description
      t.timestamps
    end
    add_index :roles, :name, unique: true

    create_table :permissions do |t|
      t.string :name, null: false
      t.string :resource, null: false
      t.string :action, null: false
      t.string :description
      t.timestamps
    end
    add_index :permissions, [ :name ], unique: true
    add_index :permissions, [ :resource, :action ]

    create_table :user_roles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.timestamps
    end
    add_index :user_roles, [ :user_id, :role_id ], unique: true

    create_table :role_permissions do |t|
      t.references :role, null: false, foreign_key: true
      t.references :permission, null: false, foreign_key: true
      t.timestamps
    end
    add_index :role_permissions, [ :role_id, :permission_id ], unique: true

    # Add current_role_id to users to track active role
    add_reference :users, :current_role, foreign_key: { to_table: :roles }, null: true

    # Don't remove the role column yet for backward compatibility
    # We'll migrate data first and then remove it in another migration
  end
end
