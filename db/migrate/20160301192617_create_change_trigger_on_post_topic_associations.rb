class CreateChangeTriggerOnPostTopicAssociations < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TRIGGER post_topic_associations_change_trigger
      BEFORE INSERT OR UPDATE OR DELETE
      ON post_topic_associations FOR EACH ROW
      EXECUTE PROCEDURE change_trigger_v2();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS post_topic_associations_change_trigger ON post_topic_associations CASCADE;
    SQL
  end
end
