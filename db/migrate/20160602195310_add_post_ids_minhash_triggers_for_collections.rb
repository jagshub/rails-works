class AddPostIdsMinhashTriggersForCollections < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION recompute_post_ids_minhash_signature_for_collection(cid integer) RETURNS void AS $$
        UPDATE collections
        SET post_ids_minhash_signature = compute_minhash_signature(30, (SELECT array_agg(post_id) FROM collection_post_associations WHERE collection_id = cid))
        WHERE id = cid
      $$ LANGUAGE SQL;
    SQL

    execute <<-SQL
      CREATE FUNCTION recompute_post_ids_minhash_signature_for_collection_trigger() RETURNS trigger AS $$
        DECLARE
        BEGIN
          PERFORM recompute_post_ids_minhash_signature_for_collection(CASE WHEN TG_OP = 'INSERT' THEN NEW.collection_id ELSE OLD.collection_id END);
          RETURN NULL;
        END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
      CREATE TRIGGER collection_post_associations_minhash_change_trigger
      AFTER INSERT OR DELETE
      ON collection_post_associations
      FOR EACH ROW EXECUTE PROCEDURE recompute_post_ids_minhash_signature_for_collection_trigger();
    SQL
  end

  def down
    execute <<-SQL
      DROP FUNCTION IF EXISTS recompute_post_ids_minhash_signature_for_collection_trigger() CASCADE;
      DROP FUNCTION IF EXISTS recompute_post_ids_minhash_signature_for_collection(integer) CASCADE;
    SQL
  end
end
