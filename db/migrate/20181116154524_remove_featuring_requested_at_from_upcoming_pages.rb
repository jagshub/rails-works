class RemoveFeaturingRequestedAtFromUpcomingPages < ActiveRecord::Migration[5.0]
  def change
    remove_column :upcoming_pages, :featuring_requested_at
  end
end
