class AddFirstTimeNewsletterRecipientFlagToSubscriber < ActiveRecord::Migration[5.2]
  def up
    add_column :notifications_subscribers, :first_time_newsletter_recipient, :boolean
    change_column_default :notifications_subscribers, :first_time_newsletter_recipient, true
  end

  def down
    remove_column :notifications_subscribers, :first_time_newsletter_recipient
  end
end
