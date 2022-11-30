class RemoveFrequencyFromNewsletterSubscription < ActiveRecord::Migration
  def change
    remove_column :newsletter_subscriptions, :frequency
  end
end
