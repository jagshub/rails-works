class AddTwitterVerifiedToUser < ActiveRecord::Migration
  def change
    add_column :users, :twitter_verified, :boolean, default: false, null: false
  end
end
