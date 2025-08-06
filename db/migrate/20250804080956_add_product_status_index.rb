class AddProductStatusIndex < ActiveRecord::Migration[8.0]
  def up
    add_index :products, :status, name: 'index_products_on_status'
    add_index :products, [ :status, :name ], name: 'index_products_on_status_and_name'
    add_index :products, [ :status, :created_at ], name: 'index_products_on_status_and_created_at'
    add_index :products, [ :status, :price ], name: 'index_products_on_status_and_price'

    execute "CREATE INDEX index_products_on_name_gin ON products USING gin (name gin_trgm_ops)"
  end

  def down
    remove_index :products, name: 'index_products_on_status'
    remove_index :products, name: 'index_products_on_status_and_name'
    remove_index :products, name: 'index_products_on_status_and_created_at'
    remove_index :products, name: 'index_products_on_status_and_price'
    execute "DROP INDEX IF EXISTS index_products_on_name_gin"
  end
end
