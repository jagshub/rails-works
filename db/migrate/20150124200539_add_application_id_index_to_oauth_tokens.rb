class AddApplicationIdIndexToOAuthTokens < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :oauth_access_tokens, :application_id, algorithm: :concurrently
  end
end
