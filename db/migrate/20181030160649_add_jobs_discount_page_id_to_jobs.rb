class AddJobsDiscountPageIdToJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :jobs, :jobs_discount_page_id, :integer, null: true
    add_index :jobs, :jobs_discount_page_id
    add_foreign_key :jobs, :jobs_discount_pages
  end
end
