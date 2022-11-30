class AddAvatarToUser < ActiveRecord::Migration
  def change
    add_column :users, :avatar, :text
  end
end
