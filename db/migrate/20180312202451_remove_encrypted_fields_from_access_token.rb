class RemoveEncryptedFieldsFromAccessToken < ActiveRecord::Migration[5.0]
  def up
    remove_column :access_tokens, :encrypted_token
    remove_column :access_tokens, :encrypted_token_salt
    remove_column :access_tokens, :encrypted_token_iv
    remove_column :access_tokens, :encrypted_secret
    remove_column :access_tokens, :encrypted_secret_salt
    remove_column :access_tokens, :encrypted_secret_iv
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
