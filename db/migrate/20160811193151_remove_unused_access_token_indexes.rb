class RemoveUnusedAccessTokenIndexes < ActiveRecord::Migration
  def change
    remove_index :oauth_access_tokens, :resource_owner_id
    remove_index :oauth_access_tokens, :application_id
  end
end
