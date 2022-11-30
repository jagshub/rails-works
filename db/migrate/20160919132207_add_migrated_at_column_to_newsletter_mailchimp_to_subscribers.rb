class AddMigratedAtColumnToNewsletterMailchimpToSubscribers < ActiveRecord::Migration
  def change
    add_column :newsletter_mailchimp_to_subscribers, :migrated_at, :datetime
  end
end
