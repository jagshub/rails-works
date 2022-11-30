class AddAppleUidToUsers < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_column :users, :apple_uid, :string, null: true
    add_index :users, :apple_uid, unique: true, algorithm: :concurrently
  end
end
