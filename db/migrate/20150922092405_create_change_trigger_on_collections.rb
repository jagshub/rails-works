class CreateChangeTriggerOnCollections < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TRIGGER collections_change_trigger
      BEFORE INSERT OR UPDATE OR DELETE
      ON collections FOR EACH ROW
      EXECUTE PROCEDURE change_trigger_v2();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS collections_change_trigger ON collections CASCADE;
    SQL
  end
end
