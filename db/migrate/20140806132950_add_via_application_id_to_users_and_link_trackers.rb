class AddViaApplicationIdToUsersAndLinkTrackers < ActiveRecord::Migration
  def change
    add_column :users, :via_application_id, :integer, null: true
    add_column :link_trackers, :via_application_id, :integer, null: true
  end
end
