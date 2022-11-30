class AddIndexIosFeaturedAtToPosts < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :posts, :ios_featured_at, algorithm: :concurrently
  end
end
