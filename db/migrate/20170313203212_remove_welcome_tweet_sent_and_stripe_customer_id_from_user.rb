class RemoveWelcomeTweetSentAndStripeCustomerIdFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :welcome_tweet_sent
    remove_column :users, :stripe_customer_id
  end
end
