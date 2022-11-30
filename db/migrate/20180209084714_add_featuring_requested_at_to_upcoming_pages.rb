class AddFeaturingRequestedAtToUpcomingPages < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_pages, :featuring_requested_at, :datetime, null: true
  end
end
