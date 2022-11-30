class AddUsersFollowerCountIndex < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :users, :follower_count, algorithm: :concurrently
  end
end
