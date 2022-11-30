class AddInteractedAtToNotificationEvents < ActiveRecord::Migration[6.1]
  def change
    return if Rails.env.production?

    add_column :notification_events, :interacted_at, :datetime, null: true
  end
end
