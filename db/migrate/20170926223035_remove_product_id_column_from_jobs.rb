class RemoveProductIdColumnFromJobs < ActiveRecord::Migration
  def change
    remove_column :jobs, :product_id, :integer
  end
end
