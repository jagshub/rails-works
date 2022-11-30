class AddUniqueIndexEmail < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :notifications_subscribers, :email, unique: true, algorithm: :concurrently
  end
end
