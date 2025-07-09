class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.decimal :price
      t.string :file_url
      t.decimal :average_rating
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
