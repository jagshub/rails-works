class CreateNewsletterMailchimpToSubscribers < ActiveRecord::Migration
  def change
    create_table :newsletter_mailchimp_to_subscribers do |t|
      t.integer :notifications_subscriber_id, null: false, foreign_key: true
      t.integer :newsletter_subscription_id, null: false, foreign_key: true
      t.boolean :active, null: false, default: false
      t.timestamps null: false
    end

    add_index :newsletter_mailchimp_to_subscribers, :active
    add_index :newsletter_mailchimp_to_subscribers, :notifications_subscriber_id, unique: true, name: 'index_newsletter_mailchimp_to_subscribers_on_subscriber_id'
    add_index :newsletter_mailchimp_to_subscribers, :newsletter_subscription_id, unique: true, name: 'index_newsletter_mailchimp_to_subscribers_on_subscription_id'
  end
end
