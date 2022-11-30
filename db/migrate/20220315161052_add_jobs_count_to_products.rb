class AddJobsCountToProducts < ActiveRecord::Migration[6.1]
  def up
    add_column :products, :jobs_count, :integer, default: 0, null: false

    Job.where.not(product_id: nil).find_each do |job|
      Product.reset_counters(job.product_id, :jobs_count)
    end
  end

  def down
    remove_column :products, :jobs_count
  end
end
