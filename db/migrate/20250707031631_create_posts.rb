class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :creator
      t.text :description
      t.date :published_date

      t.timestamps
    end
  end
end
