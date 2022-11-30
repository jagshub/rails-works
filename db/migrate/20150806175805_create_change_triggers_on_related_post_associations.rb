class CreateChangeTriggersOnRelatedPostAssociations < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TRIGGER related_post_associations_change_trigger
      BEFORE INSERT OR UPDATE OR DELETE
      ON related_post_associations FOR EACH ROW
      EXECUTE PROCEDURE change_trigger_v1();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS related_post_associations_change_trigger ON related_post_associations CASCADE;
    SQL
  end
end
