class AddPublishedIndexToJobs < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :jobs, :published, algorithm: :concurrently
  end
end
