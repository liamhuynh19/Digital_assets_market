class CreateSellerApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :seller_applications do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :status, null: false, default: "pending"
      t.text :reason, null: true
      t.text :rejection_reason, null: true
      t.datetime :reviewed_at, null: true
      t.references :reviewed_by, foreign_key: { to_table: :users }, null: true, index: true


      t.timestamps
    end
    add_index :seller_applications, [ :user_id, :status ]
  end
end
