class AddStatusToProduct < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :status, :string
    # remove_column :products, :file_url, :string
  end
end
