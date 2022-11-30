class AddTwitterTokens < ActiveRecord::Migration
  def change
    create_table :twitter_tokens do |t|
      t.references :user, null: false
      t.text :access_token, null: false
      t.text :access_secret, null: false
      t.timestamp :last_acquired_at, null: false, default: Time.at(0).to_date
    end

    add_index :twitter_tokens, :last_acquired_at
    add_column :users, :last_twitter_sync_error, :text

    reversible do |m|
      m.up do
        execute 'INSERT INTO twitter_tokens (user_id, access_token, access_secret)
                 SELECT id, twitter_access_token, twitter_access_secret
                   FROM users
                  WHERE twitter_access_token IS NOT NULL'
      end
    end
  end
end
