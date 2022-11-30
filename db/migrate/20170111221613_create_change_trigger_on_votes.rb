class CreateChangeTriggerOnVotes < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TRIGGER votes_change_trigger
      BEFORE INSERT OR UPDATE OR DELETE
      ON votes FOR EACH ROW
      EXECUTE PROCEDURE change_trigger_v2();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS votes_change_trigger ON votes CASCADE;
    SQL
  end
end
