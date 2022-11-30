class RemoveUnusedProfileImageIdFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :profile_image_id
  end
end
