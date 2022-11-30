class AddCreatedAtToUserFriendAssociation < ActiveRecord::Migration
  def change
    add_column :user_friend_associations, :created_at, :datetime
  end
end
