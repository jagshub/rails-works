class RemoveTagTables < ActiveRecord::Migration
  def up
    execute <<-SQL
      DROP FUNCTION IF EXISTS recompute_post_ids_minhash_signature_for_tag(tid integer) CASCADE;
      DROP TABLE post_tag_associations CASCADE;
      DROP TABLE tag_aliases CASCADE;
      DROP TABLE tags CASCADE;
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
