class UpdateCollectionIndices < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    remove_index :collections, :slug, if_exists: true
    # NOTE(DZ): There seems to be an index here, but it's unannotated and
    # unlikely to be working (as there are non-unique user_id-slugs in db). Drop
    # here and then recreate
    remove_index :collections, %i(slug user_id), if_exists: true

    # NOTE(DZ): Collection slugs are always unique per user scope
    add_index :collections, %i(slug user_id), unique: true, algorithm: :concurrently
    # NOTE(DZ): Featured collections need to be unique globally as well for fetching
    # This is currently broken on production with two slugs.
    add_index :collections, %i(slug), unique: true, where: 'featured_at IS NOT NULL', algorithm: :concurrently

    remove_index :collections, %i(user_id name), algorithm: :concurrently
  end
end
