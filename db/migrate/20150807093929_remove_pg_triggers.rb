class RemovePgTriggers < ActiveRecord::Migration
  def up
    execute <<-SQL
      DROP TRIGGER IF EXISTS related_post_associations_change_trigger ON related_post_associations CASCADE;
      DROP TRIGGER IF EXISTS posts_change_trigger ON posts CASCADE;
      DROP TRIGGER IF EXISTS user_friend_associations_change_trigger ON user_friend_associations CASCADE;
      DROP FUNCTION IF EXISTS change_trigger_v1() CASCADE;
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
