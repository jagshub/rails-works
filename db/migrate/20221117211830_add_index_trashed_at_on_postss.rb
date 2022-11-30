class AddIndexTrashedAtOnPostss < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    return if Rails.env.production?

    add_index :posts, :trashed_at, algorithm: :concurrently, if_not_exists: true
  end
end
