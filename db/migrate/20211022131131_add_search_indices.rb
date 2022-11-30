class AddSearchIndices < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :anthologies_stories, :title, using: :gin, opclass: { title: :gin_trgm_ops }, algorithm: :concurrently
    add_index :discussion_threads, :title, using: :gin, opclass: { title: :gin_trgm_ops }, algorithm: :concurrently
    add_index :upcoming_pages, :name, using: :gin, opclass: { name: :gin_trgm_ops }, algorithm: :concurrently
  end
end
