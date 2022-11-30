class RemoveUnusedProfileImageIndex < ActiveRecord::Migration
  def change
    remove_index :users, :profile_image_id
  end
end
