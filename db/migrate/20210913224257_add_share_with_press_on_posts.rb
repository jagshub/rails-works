class AddShareWithPressOnPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :share_with_press, :boolean, null: false, default: false
  end
end
