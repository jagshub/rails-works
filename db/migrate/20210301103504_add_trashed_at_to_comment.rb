class AddTrashedAtToComment < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_column :comments, :trashed_at, :datetime, null: true

    add_index :comments, :trashed_at, algorithm: :concurrently
  end
end
