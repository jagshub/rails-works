class AddGoogleUidToUsers < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    add_column :users, :google_uid, :string
    add_index :users, :google_uid, unique: true, algorithm: :concurrently
  end
end
