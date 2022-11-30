class AddSendCollectionDigestEmailToNotificationSettings < ActiveRecord::Migration
  def change
    add_column :notifications_settings, :send_collection_digest_email, :boolean, null: false, default: true
  end
end
