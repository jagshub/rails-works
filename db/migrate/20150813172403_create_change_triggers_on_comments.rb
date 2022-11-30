class CreateChangeTriggersOnComments < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TRIGGER comments_change_trigger
      BEFORE INSERT OR UPDATE OR DELETE
      ON comments FOR EACH ROW
      EXECUTE PROCEDURE change_trigger_v2();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS comments_change_trigger ON comments CASCADE;
    SQL
  end
end
