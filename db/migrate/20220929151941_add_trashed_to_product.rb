class AddTrashedToProduct < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :products, :trashed_at, :datetime, null: true, if_not_exists: true

    add_index :products, :trashed_at, algorithm: :concurrently, if_not_exists: true
  end
end
