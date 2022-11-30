class AddJobsIndexOnProductId < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :jobs, :product_id, algorithm: :concurrently, if_not_exists: true
  end
end
