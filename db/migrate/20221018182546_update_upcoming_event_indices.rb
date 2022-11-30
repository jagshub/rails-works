class UpdateUpcomingEventIndices < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    remove_index :upcoming_events, %i(product_id post_id), unique: true, algorithm: :concurrently

    add_index :upcoming_events, :post_id, unique: true, algorithm: :concurrently
  end
end
