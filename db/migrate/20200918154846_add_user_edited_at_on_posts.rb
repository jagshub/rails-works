class AddUserEditedAtOnPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :user_edited_at, :datetime, null: true
  end
end
