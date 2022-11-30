class DropJobsAndCompanies < ActiveRecord::Migration
  def up
    drop_table :company_post_associations
    drop_table :jobs
    drop_table :companies
  end

  def down
    # NOOP - no live code depends on this tables
  end
end
