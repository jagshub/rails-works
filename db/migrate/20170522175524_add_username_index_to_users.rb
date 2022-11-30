class AddUsernameIndexToUsers < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :users, :username, algorithm: :concurrently
  end
end
