class CleanupLinkTrackers < ActiveRecord::Migration
  def change
    remove_column :link_trackers, :from_url
    remove_column :link_trackers, :to_url
  end
end
