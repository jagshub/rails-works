class CopyAndAddTriggersToLegacyVotes < ActiveRecord::Migration
  def up

    execute <<-SQL
      INSERT INTO votes (subject_type, subject_id, user_id, credible, sandboxed, created_at, updated_at) SELECT 'Post' AS subject_type, post_id AS subject_id, user_id, credible, sandboxed, created_at, updated_at FROM post_votes;
    SQL

    execute <<-SQL
      INSERT INTO votes (subject_type, subject_id, user_id, created_at, updated_at) SELECT 'Comment' AS subject_type, comment_id AS subject_id, user_id, created_at, updated_at FROM comment_votes;
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION legacy_post_vote_sync() RETURNS trigger LANGUAGE plpgsql AS $$ DECLARE BEGIN
        IF (TG_OP <> 'INSERT') THEN
          DELETE FROM votes WHERE subject_type = 'Post' AND subject_id = OLD.post_id AND user_id = OLD.user_id;
        END IF;

        IF (TG_OP <> 'DELETE') THEN
          INSERT INTO votes (subject_type, subject_id, user_id, credible, sandboxed, created_at, updated_at) SELECT 'Post' AS subject_type, NEW.post_id AS subject_id, NEW.user_id, NEW.credible, NEW.sandboxed, NEW.created_at, NEW.updated_at;
        END IF;

        RETURN NULL;
      END; $$;

      CREATE TRIGGER legacy_post_vote_sync_trigger AFTER INSERT OR DELETE OR UPDATE ON post_votes FOR EACH ROW EXECUTE PROCEDURE legacy_post_vote_sync();
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION legacy_comment_vote_sync() RETURNS trigger LANGUAGE plpgsql AS $$ DECLARE BEGIN
        IF (TG_OP <> 'INSERT') THEN
          DELETE FROM votes WHERE subject_type = 'Comment' AND subject_id = OLD.comment_id AND user_id = OLD.user_id;
        END IF;

        IF (TG_OP <> 'DELETE') THEN
          INSERT INTO votes (subject_type, subject_id, user_id, created_at, updated_at) SELECT 'Comment' AS subject_type, NEW.comment_id AS subject_id, NEW.user_id, NEW.created_at, NEW.updated_at;
        END IF;

        RETURN NULL;
      END; $$;

      CREATE TRIGGER legacy_comment_vote_sync_trigger AFTER INSERT OR DELETE OR UPDATE ON comment_votes FOR EACH ROW EXECUTE PROCEDURE legacy_comment_vote_sync();
    SQL
  end

  def down
    execute 'DROP TRIGGER IF EXISTS legacy_post_vote_sync_trigger ON post_votes;'
    execute 'DROP FUNCTION IF EXISTS legacy_post_vote_sync();'

    execute 'DROP TRIGGER IF EXISTS legacy_comment_vote_sync_trigger ON comment_votes;'
    execute 'DROP FUNCTION IF EXISTS legacy_comment_vote_sync();'

    execute 'TRUNCATE TABLE votes';
  end
end
