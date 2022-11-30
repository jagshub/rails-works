class AddSourceToUserFriendAssociations < ActiveRecord::Migration[5.1]
  def change
    add_column :user_friend_associations, :source, :string

    add_index :user_friend_associations, :source, where: 'source IS NOT NULL'
  end
end
