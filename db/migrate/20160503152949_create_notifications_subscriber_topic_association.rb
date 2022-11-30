class CreateNotificationsSubscriberTopicAssociation < ActiveRecord::Migration
  def change
    create_table :notifications_subscriber_topic_associations do |t|
      t.integer :topic_id, null: false
      t.integer :subscriber_id, null: false

      t.timestamps null: false
    end

    add_index :notifications_subscriber_topic_associations, [:topic_id, :subscriber_id], unique: true, name: :notifications_subscriber_topic_associations_tid_sid

    add_foreign_key :notifications_subscriber_topic_associations, :topics
    add_foreign_key :notifications_subscriber_topic_associations, :notifications_subscribers, column: :subscriber_id
  end
end
