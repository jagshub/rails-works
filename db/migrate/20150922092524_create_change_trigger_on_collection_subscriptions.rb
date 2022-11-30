class CreateChangeTriggerOnCollectionSubscriptions < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TRIGGER collection_subscriptions_change_trigger
      BEFORE INSERT OR UPDATE OR DELETE
      ON collection_subscriptions FOR EACH ROW
      EXECUTE PROCEDURE change_trigger_v2();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS collection_subscriptions_change_trigger ON collection_subscriptions CASCADE;
    SQL
  end
end
