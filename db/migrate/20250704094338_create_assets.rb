class CreateAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :assets do |t|
      t.string :tite
      t.string :creator
      t.text :description
      t.date :published_date

      t.timestamps
    end
  end
end
