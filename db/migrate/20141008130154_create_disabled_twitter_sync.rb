class CreateDisabledTwitterSync < ActiveRecord::Migration
  def change
    create_table :disabled_twitter_syncs do |t|
      t.references :followed_by_user, null: false
      t.references :following_user, null: false

      t.index [:followed_by_user_id, :following_user_id], name: 'index_disabled_twitter_sync_followed_following', unique: true
    end

    add_foreign_key :disabled_twitter_syncs, :users, column: 'followed_by_user_id'
    add_foreign_key :disabled_twitter_syncs, :users, column: 'following_user_id'
  end
end
