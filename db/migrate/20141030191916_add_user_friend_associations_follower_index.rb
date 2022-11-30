class AddUserFriendAssociationsFollowerIndex < ActiveRecord::Migration
  def change
    add_index :user_friend_associations, :following_user_id
  end
end
