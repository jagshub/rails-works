class CreateChangeTriggerOnCollectionPostAssociations < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TRIGGER collection_post_associations_change_trigger
      BEFORE INSERT OR UPDATE OR DELETE
      ON collection_post_associations FOR EACH ROW
      EXECUTE PROCEDURE change_trigger_v2();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS collection_post_associations_change_trigger ON collection_post_associations CASCADE;
    SQL
  end
end
