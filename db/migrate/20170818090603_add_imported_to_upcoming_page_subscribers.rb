class AddImportedToUpcomingPageSubscribers < ActiveRecord::Migration
  def change
    add_column :upcoming_page_subscribers, :imported, :boolean, default: false, null: false
  end
end
