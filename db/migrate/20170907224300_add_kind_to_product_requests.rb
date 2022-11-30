class AddKindToProductRequests < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_column :product_requests, :kind, :integer, default: 0, null: false
    add_index :product_requests, :kind, algorithm: :concurrently
  end
end
