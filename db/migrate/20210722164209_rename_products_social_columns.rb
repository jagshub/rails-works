class RenameProductsSocialColumns < ActiveRecord::Migration[5.2]
  def change
    safety_assured {
      rename_column :products, :twitter_screen_name, :twitter_username
      rename_column :products, :instagram_handle, :instagram_username
    }
  end
end
