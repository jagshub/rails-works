class AddTrgmIndexToPost < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index(
      :posts,
      "COALESCE((name)::text, ''::text) gin_trgm_ops",
      using: :gin,
      name: 'index_posts_on_name_trgm',
      algorithm: :concurrently,
    )
  end
end
