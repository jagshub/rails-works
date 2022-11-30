class AddUserTwitterUidIndex < ActiveRecord::Migration
  def change
    execute 'commit'
    add_index :users, :twitter_uid, unique: true, algorithm: :concurrently
    execute 'begin'
  end
end
