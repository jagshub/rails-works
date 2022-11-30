class RecreateChangeTriggersOnUserFriendAssociations < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TRIGGER user_friend_associations_change_trigger
      BEFORE INSERT OR UPDATE OR DELETE
      ON user_friend_associations FOR EACH ROW
      EXECUTE PROCEDURE change_trigger_v2();
    SQL
  end


  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS user_friend_associations_change_trigger ON user_friend_associations CASCADE;
    SQL
  end
end
