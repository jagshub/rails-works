class AddPermissionsToAccessTokens < ActiveRecord::Migration
  disable_ddl_transaction!

  class AccessToken < ApplicationRecord; end

  def change
    add_column :access_tokens, :permissions, :integer, default: 0, null: true
    execute 'UPDATE access_tokens SET permissions = 0'

    AccessToken.transaction do
      execute 'LOCK access_tokens IN SHARE MODE'
      # Rewrite remaining entries (if new ones have been added)
      execute 'UPDATE access_tokens SET permissions = 0 WHERE permissions = NULL'
      change_column_null :access_tokens, :permissions, false
    end
  end
end
