class AddProductIdAndExternalCreatedAtIndexToJobs < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :jobs, :product_id, algorithm: :concurrently
    add_index :jobs, :external_created_at, algorithm: :concurrently
  end
end
