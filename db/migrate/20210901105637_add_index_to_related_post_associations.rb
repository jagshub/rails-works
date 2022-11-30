class AddIndexToRelatedPostAssociations < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :related_post_associations, [:user_id, :relationship], algorithm: :concurrently
  end
end
