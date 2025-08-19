class AddEncryptedPhoneNumberToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :encrypted_phone_number, :string
    add_column :users, :encrypted_phone_number_iv, :string
    add_index :users, :encrypted_phone_number_iv, unique: true
  end
end
