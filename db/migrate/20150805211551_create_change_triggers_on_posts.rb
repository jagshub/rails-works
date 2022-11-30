class CreateChangeTriggersOnPosts < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TRIGGER posts_change_trigger
      BEFORE INSERT OR UPDATE OR DELETE
      ON posts FOR EACH ROW
      EXECUTE PROCEDURE change_trigger_v1();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS posts_change_trigger ON posts CASCADE;
    SQL
  end
end
