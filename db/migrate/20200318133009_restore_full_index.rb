class RestoreFullIndex < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    remove_index :users, :username
    add_index :users, :username, unique: true, algorithm: :concurrently
  end
end
