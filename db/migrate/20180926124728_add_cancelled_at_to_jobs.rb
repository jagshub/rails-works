class AddCancelledAtToJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :jobs, :cancelled_at, :datetime, null: true
  end
end
