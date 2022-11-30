class ReaddAccessTokenIndexes < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    # Note(Mike): Originally I should not have removed these indexes. So I added them back into production using the sql console.
    #   The names with _x at the end are because that's what I called them when added directly.
    add_index :oauth_access_tokens, :resource_owner_id, name: 'index_oauth_access_tokens_on_resource_owner_id_x', algorithm: :concurrently
    add_index :oauth_access_tokens, :application_id, name: 'index_oauth_access_tokens_on_application_id_x', algorithm: :concurrently
  end
end
