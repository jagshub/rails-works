class AddFollowersBackend < ActiveRecord::Migration
  def change
    create_table :user_friend_associations do |t|
      t.references :followed_by_user, null: false
      t.references :following_user, null: false
    end

    add_column :users, :twitter_access_token, :text, null: true
    add_column :users, :twitter_access_secret, :text, null: true
    add_column :users, :last_twitter_sync_at, :timestamp, null: true
    add_column :users, :follower_count, :integer, null: false, default: 0
    add_column :users, :friend_count, :integer, null: false, default: 0
  end
end
