class CreateChangeTriggerOnTopicUserAssociations < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TRIGGER topic_user_associations_change_trigger
      BEFORE INSERT OR UPDATE OR DELETE
      ON topic_user_associations FOR EACH ROW
      EXECUTE PROCEDURE change_trigger_v2();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS topic_user_associations_change_trigger ON topic_user_associations CASCADE;
    SQL
  end
end
