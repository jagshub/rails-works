class AddEmailIndexToUsers < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :users, :email, algorithm: :concurrently
  end
end
