class AddSourceComponentToUserFriendAssociation < ActiveRecord::Migration[5.1]
  def change
    add_column :user_friend_associations, :source_component, :string, null: true
  end
end
