class AddAdditionalCountsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :collections_count, :integer
    add_column :users, :subscribed_collections_count, :integer
    add_column :users, :upcoming_pages_count, :integer
    add_column :users, :subscribed_upcoming_pages_count, :integer
  end
end
