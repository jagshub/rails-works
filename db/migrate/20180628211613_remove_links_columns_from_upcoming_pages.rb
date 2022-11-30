class RemoveLinksColumnsFromUpcomingPages < ActiveRecord::Migration[5.0]
  def change
    remove_column :upcoming_pages, :facebook_link
    remove_column :upcoming_pages, :twitter_link
    remove_column :upcoming_pages, :angellist_link
    remove_column :upcoming_pages, :privacy_policy_link
  end
end
