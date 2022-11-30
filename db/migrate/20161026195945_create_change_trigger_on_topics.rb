class CreateChangeTriggerOnTopics < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TRIGGER topics_change_trigger
      BEFORE INSERT OR UPDATE OR DELETE
      ON topics FOR EACH ROW
      EXECUTE PROCEDURE change_trigger_v2();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS topics_change_trigger ON topics CASCADE;
    SQL
  end
end
