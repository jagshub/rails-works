class DropNotificationsSubscriberTopicAssociations < ActiveRecord::Migration[5.0]
  def change
    drop_table :notifications_subscriber_topic_associations
  end
end
