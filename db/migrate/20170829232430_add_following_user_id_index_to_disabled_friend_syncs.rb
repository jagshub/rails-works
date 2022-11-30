class AddFollowingUserIdIndexToDisabledFriendSyncs < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :disabled_friend_syncs, :following_user_id
  end
end
