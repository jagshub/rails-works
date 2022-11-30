class RenameListsToCollections < ActiveRecord::Migration
  def change
    # Note(andreasklinger): removing the index because we need to recreate it
    #    later anyhow on for uniqueness
    remove_index :list_post_associations, :list_id_and_post_id

    rename_table :list_post_associations, :collection_post_associations
    rename_table :lists, :collections
    # Note(andreasklinger): this also handles renaming of indexes, atm no fkeys

    rename_column :collection_post_associations, :list_id, :collection_id

    change_column_null :collection_post_associations, :collection_id, false
    change_column_null :collection_post_associations, :post_id, false

    # Note(andreasklinger): re-adding index with unique constraint
    add_index :collection_post_associations, [:collection_id, :post_id], unique: true
  end
end
