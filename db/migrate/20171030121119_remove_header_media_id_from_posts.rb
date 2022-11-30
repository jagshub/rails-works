class RemoveHeaderMediaIdFromPosts < ActiveRecord::Migration[5.0]
  def change
    remove_column :posts, :header_media_id, :integer, null: true
  end
end
