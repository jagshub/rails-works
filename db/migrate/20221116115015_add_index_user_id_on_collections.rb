class AddIndexUserIdOnCollections < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    return if Rails.env.production?

    add_index :collections, :user_id, algorithm: :concurrently, if_not_exists: true
  end
end
