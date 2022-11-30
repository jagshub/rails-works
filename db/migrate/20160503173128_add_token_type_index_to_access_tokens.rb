class AddTokenTypeIndexToAccessTokens < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :access_tokens, [:token_type, :unavailable_until], algorithm: :concurrently, order: { unavailable_until: 'ASC NULLS FIRST' }
  end
end
