class AddBillingCycleAnchorToJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :jobs, :billing_cycle_anchor, :datetime
  end
end
