class AddTwitterVerifiedUsers < ActiveRecord::Migration
  def change
    create_table :twitter_verified_users do |t|
      t.text :twitter_uid
      t.text :twitter_username
      t.timestamps null: false
    end

    add_index :twitter_verified_users, :twitter_uid, unique: true
    add_index :twitter_verified_users, :twitter_username, unique: true
  end
end
