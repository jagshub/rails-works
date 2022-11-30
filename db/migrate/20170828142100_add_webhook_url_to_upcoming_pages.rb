class AddWebhookUrlToUpcomingPages < ActiveRecord::Migration
  def change
    add_column :upcoming_pages, :webhook_url, :string, null: true
  end
end
