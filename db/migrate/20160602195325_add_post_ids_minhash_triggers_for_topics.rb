class AddPostIdsMinhashTriggersForTopics < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION recompute_post_ids_minhash_signature_for_topic(tid integer) RETURNS void AS $$
        UPDATE topics
        SET post_ids_minhash_signature = compute_minhash_signature(30, (SELECT array_agg(post_id) FROM post_topic_associations WHERE topic_id = tid))
        WHERE id = tid
      $$ LANGUAGE SQL;
    SQL

    execute <<-SQL
      CREATE FUNCTION recompute_post_ids_minhash_signature_for_topic_trigger() RETURNS trigger AS $$
        DECLARE
        BEGIN
          PERFORM recompute_post_ids_minhash_signature_for_topic(CASE WHEN TG_OP = 'INSERT' THEN NEW.topic_id ELSE OLD.topic_id END);
          RETURN NULL;
        END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
      CREATE TRIGGER post_topic_associations_minhash_change_trigger
      AFTER INSERT OR DELETE
      ON post_topic_associations
      FOR EACH ROW EXECUTE PROCEDURE recompute_post_ids_minhash_signature_for_topic_trigger();
    SQL
  end

  def down
    execute <<-SQL
      DROP FUNCTION IF EXISTS recompute_post_ids_minhash_signature_for_topic_trigger() CASCADE;
      DROP FUNCTION IF EXISTS recompute_post_ids_minhash_signature_for_topic(integer) CASCADE;
    SQL
  end
end
