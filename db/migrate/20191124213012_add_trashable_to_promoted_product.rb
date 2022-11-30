class AddTrashableToPromotedProduct < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_column :promoted_products, :trashed_at, :datetime, null: true
    add_index :promoted_products, :trashed_at, where: 'trashed_at IS NULL', algorithm: :concurrently
  end
end
