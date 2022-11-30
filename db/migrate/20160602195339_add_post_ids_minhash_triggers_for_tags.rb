class AddPostIdsMinhashTriggersForTags < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION recompute_post_ids_minhash_signature_for_tag(tid integer) RETURNS void AS $$
        UPDATE tags
        SET post_ids_minhash_signature = compute_minhash_signature(30, (SELECT array_agg(post_id) FROM post_tag_associations WHERE tag_id = tid))
        WHERE id = tid
      $$ LANGUAGE SQL;
    SQL

    execute <<-SQL
      CREATE FUNCTION recompute_post_ids_minhash_signature_for_tag_trigger() RETURNS trigger AS $$
        DECLARE
        BEGIN
          PERFORM recompute_post_ids_minhash_signature_for_tag(CASE WHEN TG_OP = 'INSERT' THEN NEW.tag_id ELSE OLD.tag_id END);
          RETURN NULL;
        END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
      CREATE TRIGGER post_tag_associations_minhash_change_trigger
      AFTER INSERT OR DELETE
      ON post_tag_associations
      FOR EACH ROW EXECUTE PROCEDURE recompute_post_ids_minhash_signature_for_tag_trigger();
    SQL
  end

  def down
    execute <<-SQL
      DROP FUNCTION IF EXISTS recompute_post_ids_minhash_signature_for_tag_trigger() CASCADE;
      DROP FUNCTION IF EXISTS recompute_post_ids_minhash_signature_for_tag(integer) CASCADE;
    SQL
  end
end
