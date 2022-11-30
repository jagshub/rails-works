class MigrateTopicsAndAddTriggers < ActiveRecord::Migration
  def up
    execute <<-SQL
      INSERT INTO subscriptions (subject_type, subject_id, subscriber_id, created_at, updated_at)
        SELECT 'Topic' AS subject_type,
               following.topic_id AS subject_id,
               notifications_subscribers.id as subscriber_id,
               following.created_at,
               following.updated_at
          FROM topic_user_associations following
          JOIN notifications_subscribers
            ON notifications_subscribers.user_id = following.user_id
    SQL


    execute <<-SQL
      CREATE OR REPLACE FUNCTION legacy_topic_follow_sync() RETURNS trigger LANGUAGE plpgsql AS $$ DECLARE BEGIN
        IF (TG_OP <> 'INSERT') THEN
          DELETE FROM subscriptions
           WHERE subject_type = 'Topic'
             AND subject_id = OLD.topic_id
             AND subscriber_id = (select id from notifications_subscribers where user_id=OLD.user_id limit 1);
        END IF;

        IF (TG_OP <> 'DELETE') THEN
          INSERT INTO subscriptions (subject_type, subject_id, subscriber_id, created_at, updated_at)
            SELECT 'Topic' AS subject_type,
                   NEW.topic_id AS subject_id,
                   (select id from notifications_subscribers where user_id=NEW.user_id limit 1),
                   NEW.created_at,
                   NEW.updated_at;
        END IF;

        RETURN NULL;
      END; $$;

      CREATE TRIGGER legacy_topic_follow_sync_trigger AFTER INSERT OR DELETE OR UPDATE ON topic_user_associations FOR EACH ROW EXECUTE PROCEDURE legacy_topic_follow_sync();
    SQL
  end

  def down
    execute 'DROP TRIGGER IF EXISTS legacy_topic_follow_sync_trigger ON topic_user_associations;'
    execute 'DROP FUNCTION IF EXISTS legacy_topic_follow_sync();'

    execute 'TRUNCATE TABLE subscriptions';
  end
end
