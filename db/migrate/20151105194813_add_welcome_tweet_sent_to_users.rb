class AddWelcomeTweetSentToUsers < ActiveRecord::Migration
  def change
    add_column :users, :welcome_tweet_sent, :boolean, default: false, null: false
  end
end
