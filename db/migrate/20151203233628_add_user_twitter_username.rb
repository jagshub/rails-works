class AddUserTwitterUsername < ActiveRecord::Migration
  def change
    add_column :users, :twitter_username, :text, null: true
  end
end
