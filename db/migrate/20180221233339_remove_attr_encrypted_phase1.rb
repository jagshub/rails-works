class RemoveAttrEncryptedPhase1 < ActiveRecord::Migration[5.0]
  def change
    change_column_null(:access_tokens, :encrypted_token, true)
    change_column_null(:access_tokens, :encrypted_token_salt, true)
    change_column_null(:access_tokens, :encrypted_token_iv, true)
    add_column(:access_tokens, :token, :text)
    add_column(:access_tokens, :secret, :text)
  end
end
