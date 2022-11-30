class AddTweetSentAtToInvites < ActiveRecord::Migration
  def change
    add_column :invites, :tweet_sent_at, :datetime
  end
end
