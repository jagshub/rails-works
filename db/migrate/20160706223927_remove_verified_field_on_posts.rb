class RemoveVerifiedFieldOnPosts < ActiveRecord::Migration
  def change
    remove_column :posts, :verified, :boolean
  end
end
