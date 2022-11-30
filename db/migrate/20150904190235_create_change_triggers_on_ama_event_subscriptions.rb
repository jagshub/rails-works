class CreateChangeTriggersOnAmaEventSubscriptions < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TRIGGER ama_event_subscriptions_change_trigger
      BEFORE INSERT OR UPDATE OR DELETE
      ON ama_event_subscriptions FOR EACH ROW
      EXECUTE PROCEDURE change_trigger_v2();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS ama_event_subscriptions_change_trigger ON ama_event_subscriptions CASCADE;
    SQL
  end
end
