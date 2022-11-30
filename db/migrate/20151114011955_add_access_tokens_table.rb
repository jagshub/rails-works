class AddAccessTokensTable < ActiveRecord::Migration
  def change
    create_table :access_tokens do |t|
      t.integer :user_id, null: false
      t.integer :token_type, null: false
      t.text :encrypted_token, null: false
      t.text :encrypted_token_salt, null: false
      t.text :encrypted_token_iv, null: false
      t.text :encrypted_secret, null: true
      t.text :encrypted_secret_salt, null: true
      t.text :encrypted_secret_iv, null: true
      t.datetime :created_at, null: false
      t.datetime :expires_at, null: true
      t.datetime :unavailable_until, null: true
    end

    add_index :access_tokens, :unavailable_until
    add_index :access_tokens, [:user_id, :token_type], unique: true
  end
end
